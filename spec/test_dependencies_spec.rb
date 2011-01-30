require 'rubygems'
require 'buildr'
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib/buildr-dependency-extensions'))
require File.expand_path(File.join('spec', 'spec_helpers'), Gem::GemPathSearcher.new.find('buildr').full_gem_path)

describe 'Test dependencies' do
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
    write artifact('transitive:dependencies:jar:1.0').pom.to_s, <<-XML
<project>
  <artifactId>transitive</artifactId>
  <groupId>dependencies</groupId>

  <dependencies>
    <dependency>
      <groupId>foo</groupId>
      <artifactId>foobar</artifactId>
      <version>1.0</version>
      <scope>compile</scope>
    </dependency>
    <dependency>
      <groupId>foo</groupId>
      <artifactId>bar</artifactId>
      <version>1.0</version>
      <scope>runtime</scope>
    </dependency>
  </dependencies>
</project>
XML
  end

  describe 'duplicate artifact removal' do
    it 'should not have duplicate artifacts' do
      define "TestProject" do
        extend TransitiveDependencies
        project.version = '1.0'
        project.transitive_scopes = [:test]

        test.with 'foo:bar:jar:1.0'
        test.with 'foo:bar:jar:1.1'
      end

      expected_test_dependencies = [artifact('foo:bar:jar:1.1')]
      project('TestProject').test.dependencies.should == expected_test_dependencies
      project('TestProject').test.compile.dependencies.should == expected_test_dependencies
    end
  end

  describe 'maven describe mechanism' do
    it 'adds compile dependencies of this project to the test dependencies' do
      define "TestProject" do
        extend TransitiveDependencies
        project.version = '1.0'
        project.transitive_scopes = [:compile, :test]

        compile.with 'foo:foobar:jar:1.0'
        test.with 'foo:bar:jar:1.1'
      end

      expected_test_dependencies = [artifact('foo:bar:jar:1.1'), artifact('foo:foobar:jar:1.0')]
      project('TestProject').test.classpath.should == expected_test_dependencies
      project('TestProject').test.compile.classpath.should == expected_test_dependencies
    end

    it 'transitively adds compile dependencies and runtime dependencies of this project test dependencies to the test dependencies' do
      define "TestProject" do
        extend TransitiveDependencies
        project.version = '1.0'
        project.transitive_scopes = [:test]

        test.with 'transitive:dependencies:jar:1.0'
      end

      expected_test_dependencies = [artifact('foo:foobar:jar:1.0'), artifact('foo:bar:jar:1.0'), artifact('transitive:dependencies:jar:1.0')]
      project('TestProject').test.classpath.should ==(expected_test_dependencies)
      project('TestProject').test.compile.classpath.should ==(expected_test_dependencies)
    end

    it 'should not fail when the compile task depends on one or more file tasks' do
      define "TestProject" do
        extend TransitiveDependencies
        project.version = '1.0'

        file _(:target, :classes) do
        end
        compile.with file(_(:foo, :bar))
        test.with 'foo:bar:jar:1.1'
      end

      expected_test_dependencies = [artifact('foo:bar:jar:1.1'), file(project('TestProject').path_to(:foo, :bar))]
      project('TestProject').test.classpath.should ==(expected_test_dependencies)
      project('TestProject').test.compile.classpath.should ==(expected_test_dependencies)
    end
  end
end
