require 'spec_helper'

describe BuildrDependencyExtensions::DependencyCaching do

  before(:each) do
    Buildr.write Buildr.artifact('foo:bar:jar:1.0').pom.to_s, <<-XML
<project>
  <artifactId>bar</artifactId>
  <groupId>foo</groupId>
</project>
XML
  end

  after(:each) do
    FileUtils.rm_f(project('TestProject').path_to('dependency.cache'))
  end

  it 'reads and write the runtime dependencies to and from a dependency cache file' do
    define "TestProject" do
    end

    project = project('TestProject')
    project.run.with(artifact('foo:bar:jar:1.1'))

    dependency_caching = DependencyCaching.new(project)

    dependency_caching.write_cache

    project.run.classpath = []

    dependency_cache = dependency_caching.read_cache

    dependency_cache['runtime'].should ==([artifact('foo:bar:jar:1.1')])
  end

  it 'reads and write the compile dependencies to and from a dependency cache file' do
    define "TestProject" do
    end

    project = project('TestProject')
    project.compile.with(artifact('foo:bar:jar:1.1'))

    dependency_caching = DependencyCaching.new(project)

    dependency_caching.write_cache

    project.compile.dependencies = []

    dependency_cache = dependency_caching.read_cache

    dependency_cache['compile'].should ==([artifact('foo:bar:jar:1.1')])
  end

  it 'reads and write the test dependencies to and from a dependency cache file' do
    define "TestProject" do
    end

    project = project('TestProject')
    project.test.with(artifact('foo:bar:jar:1.1'))

    dependency_caching = DependencyCaching.new(project)

    dependency_caching.write_cache

    project.test.dependencies = project.test.compile.dependencies = []

    dependency_cache = dependency_caching.read_cache

    dependency_cache['test'].should ==([artifact('foo:bar:jar:1.1')])
  end

  it 'return nil if no dependency cache file exist' do
    define "TestProject" do
    end

    project = project('TestProject')

    dependency_caching = DependencyCaching.new(project)

    dependency_caching.read_cache.should ==(nil)
  end

  describe('cache_dependencies property') do
    it 'causes the plugin to save the dependency cache file if it does not exist when set to true' do
      dependency_caching_mock = stub('dependency_caching_mock')
      dependency_caching_mock.should_receive(:read_cache).and_return(nil)
      dependency_caching_mock.should_receive(:write_cache)
      DependencyCaching.stub!(:new).and_return(dependency_caching_mock)
      DependencyCaching.should_receive(:new).and_return(dependency_caching_mock)

      define "TestProject" do
        extend TransitiveDependencies

        project.transitive_scopes = [:compile]
        project.cache_dependencies = true

        compile.with artifact('foo:bar:jar:1.0')
      end
    end

    it 'causes the plugin to load the dependency cache file if it exists when set to true' do
      dependency_caching_mock = stub('dependency_caching_mock')
      dependency_caching_mock.should_receive(:read_cache).and_return({'compile' => [artifact('foo:bar:jar:1.0')]})
      dependency_caching_mock.should_not_receive(:write_cache)
      DependencyCaching.stub!(:new).and_return(dependency_caching_mock)
      DependencyCaching.should_receive(:new).and_return(dependency_caching_mock)

      define "TestProject" do
        extend TransitiveDependencies

        project.transitive_scopes = [:compile]
        project.cache_dependencies = true
      end

      project('TestProject').compile.dependencies.should ==([artifact('foo:bar:jar:1.0')])
    end

    it 'does not load the dependency cache file when set to false' do
      dependency_caching_mock = stub('dependency_caching_mock')
      dependency_caching_mock.should_receive(:read_cache).and_return({'compile' => [artifact('foo:bar:jar:1.0')]})
      dependency_caching_mock.should_receive(:write_cache)
      DependencyCaching.should_receive(:new).and_return(dependency_caching_mock)

      define "TestProject" do
        extend TransitiveDependencies

        project.transitive_scopes = [:compile]
      end

      project('TestProject').compile.dependencies.should ==([])
    end
  end
end
