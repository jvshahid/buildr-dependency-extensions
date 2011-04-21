require 'rubygems'
require 'buildr'
require File.expand_path(File.join(File.dirname(__FILE__), '../../lib/buildr-dependency-extensions'))
require File.expand_path(File.join('spec', 'spec_helpers'), Gem::GemPathSearcher.new.find('buildr').full_gem_path)

describe 'dependency resolution with jar dependencies' do
  it 'throws exception: undefined method depth= for JarTask' do
    define "TestProject" do
      project.version = '1.0'
      extend TransitiveDependencies
      project.transitive_scopes = [:compile]

      define 'bar' do
        extend TransitiveDependencies
        project.transitive_scopes = [:compile]
        package :jar
      end

      define 'baz' do
        extend TransitiveDependencies
        project.transitive_scopes = [:compile]
        compile.with project("bar")
        package :jar
      end
    end

    project('TestProject:baz').compile.dependencies[0].depth
  end
end
