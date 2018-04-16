# encoding: utf-8
# frozen_string_literal: true
require 'spec_helper'

describe Warden::SessionSerializer do
  before(:each) do
    @env = env_with_params
    @env['rack.session'] ||= {}
    @session = Warden::SessionSerializer.new(@env)
  end

  it "should store data for the default scope" do
    @session.store("user", :default)
    expect(@env['rack.session']).to eq({ "warden.user.default.key"=>"user" })
  end

  it "should check if a data is stored or not" do
    expect(@session).not_to be_stored(:default)
    @session.store("user", :default)
    expect(@session).to be_stored(:default)
  end

  it "should load an user from store" do
    expect(@session.fetch(:default)).to be_nil
    @session.store("user", :default)
    expect(@session.fetch(:default)).to eq("user")
  end

  it "should store data based on the scope" do
    @session.store("user", :default)
    expect(@session.fetch(:default)).to eq("user")
    expect(@session.fetch(:another)).to be_nil
  end

  it "should delete data from store" do
    @session.store("user", :default)
    expect(@session.fetch(:default)).to eq("user")
    @session.delete(:default)
    expect(@session.fetch(:default)).to be_nil
  end

  it "should delete information from store if user cannot be retrieved" do
    @session.store("user", :default)
    expect(@env['rack.session']).to have_key("warden.user.default.key")
    allow(@session).to receive(:deserialize).and_return(nil)
    @session.fetch(:default)
    expect(@env['rack.session']).not_to have_key("warden.user.default.key")
  end

  it "should support a nil session store" do
    @env['rack.session'] = nil
    expect(@session.fetch(:default)).to be_nil
  end
end
