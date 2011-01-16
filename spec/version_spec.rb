require 'rubygems'
require 'buildr'
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib/buildr-dependency-extensions'))

module BuildrDependencyExtensions

  describe Version do
    it 'should sort versions correctly' do
      version1 = Version.new '1.2.3'
      version2 = Version.new '1.2.4'
      version1.should be < version2
    end

    it 'should redefine equality as expected' do
      version1 = Version.new '1.2.3'
      version2 = Version.new '1.2.3'

      version1.should == version2
      version1.should eql(version2)
      version1.hash.should == version2.hash
    end

    it 'should return the string that was used to initialize it when to_s is called' do
      version = Version.new '1.2.3'
      version.to_s.should == '1.2.3'
    end
  end

end
