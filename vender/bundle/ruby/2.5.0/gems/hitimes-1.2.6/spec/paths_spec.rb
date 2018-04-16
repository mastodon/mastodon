require 'spec_helper'

describe Hitimes::Paths do
  it "can access the root dir of the project" do
    Hitimes::Paths.root_dir.must_equal File.expand_path( File.join( File.dirname( __FILE__ ), ".." ) ) + ::File::SEPARATOR
  end

  it "can access the lib path of the project" do
    Hitimes::Paths.lib_path.must_equal File.expand_path( File.join( File.dirname( __FILE__ ), "..", "lib" ) ) + ::File::SEPARATOR
  end
end
