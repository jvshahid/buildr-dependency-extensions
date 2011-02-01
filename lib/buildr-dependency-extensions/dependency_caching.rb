require 'yaml'

module BuildrDependencyExtensions
  class DependencyCaching
    def initialize project
      @project = project
    end

    def write_cache
      dependencies_cache = {}
      dependencies_cache['runtime'] = @project.run.classpath.
        select {|dep| HelperFunctions.is_artifact?(dep)}.
        map    {|dep| dep.to_spec}

      dependencies_cache['compile'] = @project.compile.dependencies.to_a.
        select {|dep| HelperFunctions.is_artifact?(dep)}.
        map    {|dep| dep.to_spec}

      dependencies_cache['test'] = @project.test.dependencies.to_a.
        select {|dep| HelperFunctions.is_artifact?(dep)}.
        map    {|dep| dep.to_spec}

      dependency_caching_filename = @project.path_to('dependency.cache')
      f = File.new(dependency_caching_filename, 'w')
      f.write(dependencies_cache.to_yaml)
      f.close
    end

    def read_cache
      begin
        dependency_caching_filename = @project.path_to('dependency.cache')
        dependdencies_cache = YAML.load_file(dependency_caching_filename)

        runtime_dependencies = dependdencies_cache['runtime']
        compile_dependencies = dependdencies_cache['compile']
        test_dependencies = dependdencies_cache['test']

        dependdencies_cache['runtime'] = runtime_dependencies.map {|dep| @project.artifact(dep)}
        dependdencies_cache['compile'] = compile_dependencies.map {|dep| @project.artifact(dep)}
        dependdencies_cache['test']    = test_dependencies.map {|dep| @project.artifact(dep)}
        dependdencies_cache
      rescue Errno::ENOENT
        nil
      end
    end
  end
end
