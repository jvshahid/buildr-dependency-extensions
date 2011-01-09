require 'rubygems'
require 'buildr'
require 'lib/helper'

include DependencyLocking

describe DependencyLocking::HelperFunctions do
  it 'should return a set of artifacts with version set to 0 when get_unique_group_artifact is called with a set of artifacts' do
    original_set = ['foo:bar:jar:1.0', 'bar:foo:jar:2.0']
    actual_set = HelperFunctions.get_unique_group_artifact original_set
    expected_set = ['foo:bar:jar:0', 'bar:foo:jar:0']
    actual_set.should == expected_set
  end

  it 'should return a array of unique artifacts when get_unique_group_artifact is called with a set of artifacts' do
    original_set = ['foo:bar:jar:1.0', 'foo:bar:jar:2.0']
    actual_set = HelperFunctions.get_unique_group_artifact original_set
    expected_set = ['foo:bar:jar:0']
    actual_set.should == expected_set
  end

  it 'should return all versions in descending order when get_all_versions is called given an artifact (with version set to 0) and a set of artifacts' do
    artifact = 'foo:bar:jar:0'
    original_set = ['foo:bar:jar:1.0', 'foo:bar:jar:2.0']
    actual_versions = HelperFunctions.get_all_versions artifact, original_set
    expected_versions = [Version.new('2.0'), Version.new('1.0')]
    actual_versions.should == expected_versions
  end

  it 'should not return repeated versions when get_all_versions is called' do
    artifact = 'foo:bar:jar:0'
    original_set = ['foo:bar:jar:1.0', 'foo:bar:jar:1.0']
    actual_versions = HelperFunctions.get_all_versions artifact, original_set
    expected_versions = [Version.new('1.0')]
    actual_versions.should == expected_versions
  end
end
