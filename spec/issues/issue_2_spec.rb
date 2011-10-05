require 'spec_helper'

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
