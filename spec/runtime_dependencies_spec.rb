require 'rubygems'
require 'buildr'
require 'lib/transitive-buildr'

require File.expand_path(File.join('spec', 'spec_helpers'), Gem::GemPathSearcher.new.find('buildr').full_gem_path)

describe 'Runtime dependencies' do
  before(:each) do
    write artifact('foo:bar:jar:1.0').pom.to_s, <<-XML
<project>
  <artifactId>bar</artifactId>
  <groupId>foo</groupId>
</project>
XML

    write artifact('foo:bar:jar:1.1').pom.to_s, <<-XML
<project>
  <artifactId>bar</artifactId>
  <groupId>foo</groupId>
</project>
XML

    write artifact('foo:foobar:jar:1.0').pom.to_s, <<-XML
<project>
  <artifactId>foobar</artifactId>
  <groupId>foo</groupId>
</project>
XML
  end

  it 'should not have duplicate artifacts' do
    define "TestProject" do
      extend TransitiveDependencies
      project.version = '1.0'

      run.with 'foo:bar:jar:1.0'
      run.with 'foo:bar:jar:1.1'
    end

    expected_runtime_dependencies = [artifact('foo:bar:jar:1.1')]
    actual_runtime_dependencies = project('TestProject').run.classpath
    actual_runtime_dependencies.should == expected_runtime_dependencies
  end

  it 'should have the compile task dependencies' do
    define "TestProject" do
      extend TransitiveDependencies
      project.version = '1.0'

      compile.with 'foo:foobar:jar:1.0'
      run.with 'foo:bar:jar:1.1'
    end

    expected_runtime_dependencies = [artifact('foo:foobar:jar:1.0'), artifact('foo:bar:jar:1.1')]
    actual_runtime_dependencies = project('TestProject').run.classpath
    actual_runtime_dependencies.should == expected_runtime_dependencies
  end

  it 'should not fail when the compile task depends on one or more file tasks' do
    define "TestProject" do
      extend TransitiveDependencies
      project.version = '1.0'

      file _(:target, :classes) do
      end
      compile.with file(_(:foo, :bar))
      run.with 'foo:bar:jar:1.1'
    end

    expected_runtime_dependencies = [artifact('foo:bar:jar:1.1'), file(project('TestProject').path_to(:foo, :bar))]
    actual_runtime_dependencies = project('TestProject').run.classpath
    actual_runtime_dependencies.should == expected_runtime_dependencies
  end
end
