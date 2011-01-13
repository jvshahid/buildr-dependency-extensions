require 'buildr/core/project'
require 'yaml'

module TransitiveBuildr

  include Extension

  after_define do |project|
    compile_dependencies = project.compile.dependencies.select {|dep| HelperFunctions.is_artifact? dep }
    runtime_dependencies = compile_dependencies + project.run.classpath
    runtime_file_tasks = runtime_dependencies.reject {|dep| HelperFunctions.is_artifact? dep }
    runtime_artifacts = runtime_dependencies - runtime_file_tasks
    transitive_runtime_artifacts = runtime_artifacts.inject([]) do |set, dependency|
      set + project.transitive(dependency)
    end
    unique_transitive_artifacts = HelperFunctions.get_unique_group_artifact(transitive_runtime_artifacts)
    version_conflict_resolver = HighestVersionConflictResolver.new
    new_runtime_artifacts = unique_transitive_artifacts.map do |artifact|
      all_versions = HelperFunctions.get_all_versions artifact, transitive_runtime_artifacts
      artifact_hash = Artifact.to_hash(artifact)
      artifact_hash[:version] = version_conflict_resolver.resolve artifact, all_versions
      project.artifact(Artifact.to_spec(artifact_hash))
    end
    project.run.classpath = new_runtime_artifacts + runtime_file_tasks
  end
end
