# encoding: utf-8
# frozen_string_literal: true
require 'spec_helper'

describe Warden::Proxy::Errors do

  before(:each) do
    @errors = Warden::Proxy::Errors.new
  end

  it "should report that it is empty on first creation" do
    expect(@errors).to be_empty
  end

  it "should continue to report that it is empty even after being checked" do
    @errors.on(:foo)
    expect(@errors).to be_empty
  end

  it "should add an error" do
    @errors.add(:login, "Login or password incorrect")
    expect(@errors[:login]).to eq(["Login or password incorrect"])
  end

  it "should allow many errors to be added to the same field" do
    @errors.add(:login, "bad 1")
    @errors.add(:login, "bad 2")
    expect(@errors.on(:login)).to eq(["bad 1", "bad 2"])
  end

  it "should give the full messages for an error" do
    @errors.add(:login, "login wrong")
    @errors.add(:password, "password wrong")
    ["password wrong", "login wrong"].each do |msg|
      expect(@errors.full_messages).to include(msg)
    end
  end

  it "should return the error for a specific field / label" do
    @errors.add(:login, "wrong")
    expect(@errors.on(:login)).to eq(["wrong"])
  end

  it "should return nil for a specific field if it's not been set" do
    expect(@errors.on(:not_there)).to be_nil
  end

end
