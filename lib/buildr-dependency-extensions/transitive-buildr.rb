require 'buildr/core/project'
require 'yaml'

module BuildrDependencyExtensions
  module TransitiveDependencies

    include Extension

    @@conflict_resolver = HighestVersionConflictResolver.new

    def self.extended(base)
      class << base
        def transitive_scopes= scopes
          @transitive_scopes = scopes
        end

        def transitive_scopes
          @transitive_scopes
        end
      end
      super
    end

    after_define(:'transitive-dependencies' => :run) do |project|
      if project.transitive_scopes
        resolve_dependencies project, project.compile if project.transitive_scopes.include? :compile
        resolve_dependencies project, project.run     if project.transitive_scopes.include? :run
        resolve_dependencies project, project.test    if project.transitive_scopes.include? :test
      end
    end

    module_function

    def get_scope_dependencies scope_task
      if scope_task.respond_to?(:dependencies)
        scope_task.dependencies
      else
        scope_task.classpath
      end
    end

    def set_scope_dependencies scope_task, new_dependencies
      if scope_task.respond_to?(:dependencies=)
        scope_task.dependencies = new_dependencies
      else
        scope_task.classpath = new_dependencies
      end
    end

    def resolve_dependencies project, scope_task
      scope_dependencies = get_scope_dependencies(scope_task)
      scope_artifacts    = scope_dependencies.select {|dep| HelperFunctions.is_artifact? dep }
      scope_file_tasks   = scope_dependencies.reject {|dep| HelperFunctions.is_artifact? dep }

      transitive_scope_artifacts = scope_artifacts.inject([]) do |set, dependency|
        set + project.transitive(dependency)
      end

      unique_transitive_artifacts = HelperFunctions.get_unique_group_artifact(transitive_scope_artifacts)
      new_scope_artifacts = unique_transitive_artifacts.map do |artifact|
        all_versions = HelperFunctions.get_all_versions artifact, transitive_scope_artifacts
        artifact_hash = Artifact.to_hash(artifact)
        artifact_hash[:version] = @@conflict_resolver.resolve artifact, all_versions
        project.artifact(Artifact.to_spec(artifact_hash))
      end
      new_scope_dependencies = new_scope_artifacts + scope_file_tasks
      set_scope_dependencies(scope_task, new_scope_dependencies)
    end
  end
end
