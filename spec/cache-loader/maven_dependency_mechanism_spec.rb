require 'spec_helper'

describe 'Maven' do
  before(:each) do
    write artifact('foo:bar:jar:2.0').pom.to_s, <<-XML
<project>
  <artifactId>bar</artifactId>
  <groupId>foo</groupId>
</project>
XML

    write artifact('foo:bar:jar:2.1').pom.to_s, <<-XML
<project>
  <artifactId>bar</artifactId>
  <groupId>foo</groupId>
</project>
XML

    write artifact('transitive:dependencies:jar:2.0').pom.to_s, <<-XML
<project>
  <artifactId>transitive</artifactId>
  <groupId>dependencies</groupId>

  <dependencies>
    <dependency>
      <groupId>foo</groupId>
      <artifactId>bar</artifactId>
      <version>2.1</version>
      <scope>runtime</scope>
    </dependency>
  </dependencies>
</project>
XML
  end

  describe 'version conflict resolver' do
    it 'uses the depth of the dependency to resolve version conflicts' do
      define "TestProject" do
        extend TransitiveDependencies
        project.version = '1.0'

        project.transitive_scopes = [:run]

        run.with 'foo:bar:jar:2.0'
        run.with 'transitive:dependencies:jar:2.0'

      end

      expected_dependencies = [artifact('foo:bar:jar:2.0'), artifact('transitive:dependencies:jar:2.0')]
      project('TestProject').run.classpath.should ==(expected_dependencies)
    end
  end
end
