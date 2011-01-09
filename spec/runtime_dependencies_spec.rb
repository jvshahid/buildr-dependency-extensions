require 'rubygems'
require 'buildr'
require 'lib/dependency_lock'

require '/home/jshahid/.rvm/gems/ruby-1.8.7-p302/gems/buildr-1.4.4/spec/spec_helpers'

describe 'Runtime dependencies' do
  it 'should not have duplicate artifacts' do
    define "TestProject" do
      extend DependencyLocking

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
