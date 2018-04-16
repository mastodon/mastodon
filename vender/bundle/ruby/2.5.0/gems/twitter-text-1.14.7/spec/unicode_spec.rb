# encoding: utf-8
require File.dirname(__FILE__) + '/spec_helper'

describe Twitter::Unicode do

  it "should lazy-init constants" do
    Twitter::Unicode.const_defined?(:UFEB6).should == false
    Twitter::Unicode::UFEB6.should_not be_nil
    Twitter::Unicode::UFEB6.should be_kind_of(String)
    Twitter::Unicode.const_defined?(:UFEB6).should == true
  end

  it "should return corresponding character" do
    Twitter::Unicode::UFEB6.should == [0xfeb6].pack('U')
  end

  it "should allow lowercase notation" do
    Twitter::Unicode::Ufeb6.should == Twitter::Unicode::UFEB6
    Twitter::Unicode::Ufeb6.should === Twitter::Unicode::UFEB6
  end

  it "should allow underscore notation" do
    Twitter::Unicode::U_FEB6.should == Twitter::Unicode::UFEB6
    Twitter::Unicode::U_FEB6.should === Twitter::Unicode::UFEB6
  end

  it "should raise on invalid codepoints" do
    lambda { Twitter::Unicode::FFFFFF }.should raise_error(NameError)
  end

end
