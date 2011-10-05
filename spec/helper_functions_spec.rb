require 'rubygems'
require 'buildr'
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib/buildr-dependency-extensions'))

module BuildrDependencyExtensions

  describe HelperFunctions do
    describe 'get_unique_group_artifact' do
      it 'should return a set of artifacts with version set to 0 given a set of artifacts' do
        original_set = ['foo:bar:jar:1.0', 'bar:foo:jar:2.0']
        actual_set = HelperFunctions.get_unique_group_artifact original_set
        expected_set = ['foo:bar:jar:0', 'bar:foo:jar:0']
        actual_set.should == expected_set
      end

      it 'should return a array of unique artifacts given a set of artifacts' do
        original_set = ['foo:bar:jar:1.0', 'foo:bar:jar:2.0']
        actual_set = HelperFunctions.get_unique_group_artifact original_set
        expected_set = ['foo:bar:jar:0']
        actual_set.should == expected_set
      end

    end

    describe 'get_all_versions' do
      it 'should return all versions in descending order given an artifact and a set of artifacts' do
        artifact = 'foo:bar:jar:0'
        original_set = ['foo:bar:jar:1.0', 'foo:bar:jar:2.0']
        actual_versions = HelperFunctions.get_all_versions artifact, original_set
        expected_versions = [Version.new('2.0'), Version.new('1.0')]
        actual_versions.should == expected_versions
      end

      it 'should return one version only if given an artifact and a set of artifacts with one occurence of the given artifact' do
        artifact = 'foo:foobar:jar:0'
        original_set = ['foo:bar:jar:1.0', 'foo:bar:jar:2.0', 'foo:foobar:jar:1.0']
        actual_versions = HelperFunctions.get_all_versions artifact, original_set
        expected_versions = [Version.new('1.0')]
        actual_versions.should == expected_versions
      end

      it 'should not return repeated versions' do
        artifact = 'foo:bar:jar:0'
        original_set = ['foo:bar:jar:1.0', 'foo:bar:jar:1.0']
        actual_versions = HelperFunctions.get_all_versions artifact, original_set
        expected_versions = [Version.new('1.0')]
        actual_versions.should == expected_versions
      end

    end
  end

end
