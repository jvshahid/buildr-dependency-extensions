require 'rubygems'
require 'buildr'
require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'lib', 'buildr-dependency-extensions'))
require File.expand_path(File.join('spec', 'spec_helpers'), Gem::GemPathSearcher.new.find('buildr').full_gem_path)

describe 'Issue 1, mockito 1.8.1-rc1 is chosen instead of 1.8.5' do
  before(:each) do
    write artifact('foo:bar:jar:1.2').pom.to_s, <<-XML
<project>
  <artifactId>bar</artifactId>
  <groupId>fuu</groupId>

  <dependencies>
    <dependency>
      <groupId>org.mockito</groupId>
      <artifactId>mockito</artifactId>
      <version>1.8.1-rc1</version>
      <scope>test</scope>
    </dependency>
  </dependencies>
</project>
XML

    write artifact('org.mockito:mockito:jar:1.8.5').pom.to_s, <<-XML
<project>
  <artifactId>mockito</artifactId>
  <groupId>org.mockito</groupId>
</project>
XML

    write artifact('org.mockito:mockito:jar:1.8.1-rc1').pom.to_s, <<-XML
<project>
  <artifactId>mockito</artifactId>
  <groupId>org.mockito</groupId>
</project>
XML

  end

  it 'should not use mockito 1.8.5 instead of 1.8.1-rc1' do
    define "Issue1Project" do
      extend TransitiveDependencies
      project.version = '1.0'
      project.transitive_scopes = [:compile, :test]

      compile.with 'foo:bar:jar:1.2'
      test.with 'org.mockito:mockito:jar:1.8.5'
    end

    expected_test_dependencies = [artifact('org.mockito:mockito:jar:1.8.5'), artifact('foo:bar:jar:1.2')]
    actual_test_dependencies = project('Issue1Project').test.dependencies
    actual_test_dependencies.should == expected_test_dependencies
  end
end
