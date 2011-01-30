require 'rubygems'
require 'buildr'
require 'xmlsimple'
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib/buildr-dependency-extensions'))


describe BuildrDependencyExtensions::PomGenerator do
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

  it "should not add any dependencies if PomGenerator isn't included" do
    define "TestProject" do
      extend TransitiveDependencies

      project.version = '1.0-SNAPSHOT'
      project.group = 'foo.bar'
      compile.with 'foo:bar:jar:1.0'
    end

    pom = project('TestProject').package(:jar).pom
    pom.invoke
    generated_pom_hash = XmlSimple.xml_in(File.open(pom.to_s).read, {'ForceArray' => false})
    expected_pom_hash = {
      'modelVersion' => '4.0.0',
      'groupId'      => 'foo.bar',
      'artifactId'   => 'TestProject',
      'version'      => '1.0-SNAPSHOT'
    }
    generated_pom_hash.should eql expected_pom_hash
  end

  it 'should add all compile dependencies with compile scope' do
    define "TestProject" do
      extend PomGenerator

      project.version = '1.0-SNAPSHOT'
      project.group = 'foo.bar'
      compile.with 'foo:bar:jar:1.0'
    end

    pom = project('TestProject').package(:jar).pom
    pom.invoke
    generated_pom_hash = XmlSimple.xml_in(File.open(pom.to_s).read, {'ForceArray' => ['dependencies']})
    expected_pom_hash = {
      'modelVersion' => '4.0.0',
      'groupId'      => 'foo.bar',
      'artifactId'   => 'TestProject',
      'version'      => '1.0-SNAPSHOT',
      'dependencies' =>
      [{ 'dependency' => {
           'groupId'    => 'foo',
           'artifactId' => 'bar',
           'version'    => '1.0',
           'scope'      => 'compile',
           'type'       => 'jar'
         }
       }]
    }
    generated_pom_hash.should eql expected_pom_hash
  end

  it 'should add all runtime dependencies with runtime scope' do
    define "TestProject" do
      extend PomGenerator

      project.version = '1.0-SNAPSHOT'
      project.group = 'foo.bar'
      run.with ['foo:bar:jar:1.0', 'foo:foobar:jar:1.0']
    end

    pom = project('TestProject').package(:jar).pom
    pom.invoke
    generated_pom_hash = XmlSimple.xml_in(File.open(pom.to_s).read, {'ForceArray' => ['dependencies']})
    expected_pom_hash = {
      'modelVersion' => '4.0.0',
      'groupId'      => 'foo.bar',
      'artifactId'   => 'TestProject',
      'version'      => '1.0-SNAPSHOT',
      'dependencies' =>
      [{ 'dependency' => {
           'groupId'    => 'foo',
           'artifactId' => 'bar',
           'version'    => '1.0',
           'scope'      => 'runtime',
           'type'       => 'jar'
         }
       },
       {  'dependency' => {
           'groupId'    => 'foo',
           'artifactId' => 'foobar',
           'version'    => '1.0',
           'scope'      => 'runtime',
           'type'       => 'jar'
         }
       }]
    }
    generated_pom_hash.should eql expected_pom_hash
  end

  it 'should add all test dependencies with test scope' do
    define "TestProject" do
      extend PomGenerator

      project.version = '1.0-SNAPSHOT'
      project.group = 'foo.bar'
      test.with 'foo:bar:jar:1.0'
    end

    pom = project('TestProject').package(:jar).pom
    pom.invoke
    generated_pom_hash = XmlSimple.xml_in(File.open(pom.to_s).read, {'ForceArray' => ['dependencies']})
    expected_pom_hash = {
      'modelVersion' => '4.0.0',
      'groupId'      => 'foo.bar',
      'artifactId'   => 'TestProject',
      'version'      => '1.0-SNAPSHOT',
      'dependencies' =>
      [{ 'dependency' => {
           'groupId'    => 'foo',
           'artifactId' => 'bar',
           'version'    => '1.0',
           'scope'      => 'test',
           'type'       => 'jar'
         }
       }]
    }
    generated_pom_hash.should eql expected_pom_hash
  end
end
