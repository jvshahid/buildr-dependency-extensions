require 'rubygems'
require 'buildr'
require 'lib/transitive-buildr'


describe 'TransitiveBuildr pom generator' do
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

  it 'should add all compile dependencies with compile scope' do
    define "TestProject" do
      extend TransitiveBuildr

      project.version = '1.0-SNAPSHOT'
      project.group = 'foo.bar'
      compile.with 'foo:bar:jar:1.0'
    end

    pom = project('TestProject').package(:jar).pom
    pom.invoke
    generated_pom = File.open(pom.to_s).read
    expected_pom = <<-POM
<?xml version="1.0" encoding="UTF-8"?>
<project>
  <modelVersion>4.0.0</modelVersion>
  <groupId>foo.bar</groupId>
  <artifactId>TestProject</artifactId>
  <version>1.0-SNAPSHOT</version>

  <dependencies>
    <dependency>
      <groupId>foo</groupId>
      <artifactId>bar</artifactId>
      <version>1.0</version>
      <scope>compile</scope>
      <type>jar</type>
    </dependency>
  </dependencies>
</project>
POM
    generated_pom.should eql expected_pom
  end

  it 'should add all runtime dependencies with runtime scope' do
    define "TestProject" do
      extend TransitiveBuildr

      project.version = '1.0-SNAPSHOT'
      project.group = 'foo.bar'
      run.with ['foo:bar:jar:1.0', 'foo:foobar:jar:1.0']
    end

    pom = project('TestProject').package(:jar).pom
    pom.invoke
    generated_pom = File.open(pom.to_s).read
    expected_pom = <<-POM
<?xml version="1.0" encoding="UTF-8"?>
<project>
  <modelVersion>4.0.0</modelVersion>
  <groupId>foo.bar</groupId>
  <artifactId>TestProject</artifactId>
  <version>1.0-SNAPSHOT</version>

  <dependencies>
    <dependency>
      <groupId>foo</groupId>
      <artifactId>bar</artifactId>
      <version>1.0</version>
      <scope>runtime</scope>
      <type>jar</type>
    </dependency>
    <dependency>
      <groupId>foo</groupId>
      <artifactId>foobar</artifactId>
      <version>1.0</version>
      <scope>runtime</scope>
      <type>jar</type>
    </dependency>
  </dependencies>
</project>
POM
    generated_pom.should eql expected_pom
  end

  it 'should add all test dependencies with test scope' do
    define "TestProject" do

      extend TransitiveBuildr

      project.version = '1.0-SNAPSHOT'
      project.group = 'foo.bar'
      test.with 'foo:bar:jar:1.0'
    end

    pom = project('TestProject').package(:jar).pom
    pom.invoke
    generated_pom = File.open(pom.to_s).read
    expected_pom = <<-POM
<?xml version="1.0" encoding="UTF-8"?>
<project>
  <modelVersion>4.0.0</modelVersion>
  <groupId>foo.bar</groupId>
  <artifactId>TestProject</artifactId>
  <version>1.0-SNAPSHOT</version>

  <dependencies>
    <dependency>
      <groupId>foo</groupId>
      <artifactId>bar</artifactId>
      <version>1.0</version>
      <scope>test</scope>
      <type>jar</type>
    </dependency>
  </dependencies>
</project>
POM
    generated_pom.should eql expected_pom
  end
end
