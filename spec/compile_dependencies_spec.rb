require 'rubygems'
require 'buildr'
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib/buildr-dependency-extensions'))
require File.expand_path(File.join('spec', 'spec_helpers'), Gem::GemPathSearcher.new.find('buildr').full_gem_path)

describe 'Compile dependencies' do
  before(:each) do
    write artifact('foo:bar:jar:1.0').pom.to_s, <<-XML
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

  describe 'maven dependency mechanism' do
    it 'transitively adds compile dependencies and runtime dependencies of this project runtime dependencies to the runtime dependencies' do
      define "TestProject" do
        extend TransitiveDependencies
        project.version = '1.0'

        project.transitive_scopes = [:compile]

        compile.with 'transitive:dependencies:jar:1.0'
      end

      expected_dependencies = [artifact('foo:foobar:jar:1.0'), artifact('transitive:dependencies:jar:1.0')]
      project('TestProject').compile.dependencies.should ==(expected_dependencies)
    end
  end
end
