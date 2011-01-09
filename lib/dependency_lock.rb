require 'buildr/core/project'
require 'yaml'
require 'helper'
require 'resolver'

module DependencyLocking

  include Extension

  after_define do |project|
    runtime_dependencies = project.compile.dependencies + project.run.classpath
    transitive_runtime_dependencies = runtime_dependencies.inject([]) do |set, dependency|
      set + project.transitive(dependency)
    end
    unique_transitive_dependencies = HelperFunctions.get_unique_group_artifact(transitive_runtime_dependencies)
    version_conflict_resolver = HighestVersionConflictResolver.new
    new_runtime_dependencies = unique_transitive_dependencies.map do |artifact|
      all_versions = HelperFunctions.get_all_versions artifact, transitive_runtime_dependencies
      artifact_hash = Artifact.to_hash(artifact)
      artifact_hash[:version] = version_conflict_resolver.resolve artifact, all_versions
      project.artifact(Artifact.to_spec(artifact_hash))
    end
    project.run.classpath = new_runtime_dependencies
  end
end
