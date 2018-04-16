# encoding: utf-8
require File.dirname(__FILE__) + '/spec_helper'

class TestValidation
  include Twitter::Validation
end

describe Twitter::Validation do

  it "should disallow invalid BOM character" do
    TestValidation.new.tweet_invalid?("Bom:#{Twitter::Unicode::UFFFE}").should == :invalid_characters
    TestValidation.new.tweet_invalid?("Bom:#{Twitter::Unicode::UFEFF}").should == :invalid_characters
  end

  it "should disallow invalid U+FFFF character" do
    TestValidation.new.tweet_invalid?("Bom:#{Twitter::Unicode::UFFFF}").should == :invalid_characters
  end

  it "should disallow direction change characters" do
    [0x202A, 0x202B, 0x202C, 0x202D, 0x202E].map{|cp| [cp].pack('U') }.each do |char|
      TestValidation.new.tweet_invalid?("Invalid:#{char}").should == :invalid_characters
    end
  end

  it "should disallow non-Unicode" do
    TestValidation.new.tweet_invalid?("not-Unicode:\xfff0").should == :invalid_characters
  end

  it "should allow <= 140 combined accent characters" do
    char = [0x65, 0x0301].pack('U')
    TestValidation.new.tweet_invalid?(char * 139).should == false
    TestValidation.new.tweet_invalid?(char * 140).should == false
    TestValidation.new.tweet_invalid?(char * 141).should == :too_long
  end

  it "should allow <= 140 multi-byte characters" do
    char = [ 0x1d106 ].pack('U')
    TestValidation.new.tweet_invalid?(char * 139).should == false
    TestValidation.new.tweet_invalid?(char * 140).should == false
    TestValidation.new.tweet_invalid?(char * 141).should == :too_long
  end

end
