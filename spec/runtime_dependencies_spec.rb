require 'rubygems'
require 'buildr'
require 'lib/dependency_lock'

require File.expand_path(File.join('spec', 'spec_helpers'), Gem::GemPathSearcher.new.find('buildr').full_gem_path)

describe 'Runtime dependencies' do
  it 'should not have duplicate artifacts' do
    define "TestProject" do
      extend TransitiveBuildr

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

      run.with 'foo:bar:jar:1.0'
      run.with 'foo:bar:jar:1.1'
    end

    expected_runtime_dependencies = [artifact('foo:bar:jar:1.1')]
    actual_runtime_dependencies = project('TestProject').run.classpath
    actual_runtime_dependencies.should == expected_runtime_dependencies
  end
end
