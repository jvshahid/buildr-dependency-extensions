require 'rubygems'
require 'buildr'
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib/buildr-dependency-extensions'))
require File.expand_path(File.join('spec', 'spec_helpers'), Gem::GemPathSearcher.new.find('buildr').full_gem_path)

describe BuildrDependencyExtensions::DependencyCaching do
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
end
