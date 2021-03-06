require_relative 'spec_helper'

describe Kernel do
  def self.get_requires
    Dir.chdir File.expand_path(File.dirname(__FILE__)) + '/../lib'
    filenames = Dir.glob 'tailor/*.rb'
    requires = filenames.each do |fn|
      fn.chomp!(File.extname(fn))
    end
    return requires
  end

  # Try to require each of the files in Tailor
  get_requires.each do |r|
    it "should require #{r}" do
      # A require returns true if it was required, false if it had already been
      #   required, and nil if it couldn't require.
      Kernel.require(r.to_s).should_not be_nil
    end
  end
end

describe Tailor do
  it "should have a VERSION constant" do
    Tailor.const_defined?('VERSION').should == true
  end
end
