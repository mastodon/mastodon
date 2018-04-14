# encoding: utf-8
# frozen_string_literal: true
require 'spec_helper'

describe "authenticated data store" do

  before(:each) do
    @env = env_with_params
    @env['rack.session'] = {
      "warden.user.foo.key"     => "foo user",
      "warden.user.default.key" => "default user",
      :foo => "bar"
    }
  end

  it "should store data for the default scope" do
    app = lambda do |e|
      e['warden'].authenticate(:pass)
      e['warden'].authenticate(:pass, :scope => :foo)
      expect(e['warden']).to be_authenticated
      expect(e['warden']).to be_authenticated(:foo)

      # Store the data for :default
      e['warden'].session[:key] = "value"
      valid_response
    end
    setup_rack(app).call(@env)
    expect(@env['rack.session']['warden.user.default.session']).to eq(key: "value")
    expect(@env['rack.session']['warden.user.foo.session']).to be_nil
  end

  it "should store data for the foo user" do
    app = lambda do |e|
      e['warden'].session(:foo)[:key] = "value"
      valid_response
    end
    setup_rack(app).call(@env)
    expect(@env['rack.session']['warden.user.foo.session']).to eq(key: "value")
  end

  it "should store the data separately" do
    app = lambda do |e|
      e['warden'].session[:key] = "value"
      e['warden'].session(:foo)[:key] = "another value"
      valid_response
    end
    setup_rack(app).call(@env)
    expect(@env['rack.session']['warden.user.default.session']).to eq(key: "value")
    expect(@env['rack.session']['warden.user.foo.session'    ]).to eq(key: "another value")
  end

  it "should clear the foo scoped data when foo logs out" do
    app = lambda do |e|
      e['warden'].session[:key] = "value"
      e['warden'].session(:foo)[:key] = "another value"
      e['warden'].logout(:foo)
      valid_response
    end
    setup_rack(app).call(@env)
    expect(@env['rack.session']['warden.user.default.session']).to eq(key: "value")
    expect(@env['rack.session']['warden.user.foo.session'    ]).to be_nil
  end

  it "should clear out the default data when :default logs out" do
    app = lambda do |e|
      e['warden'].session[:key] = "value"
      e['warden'].session(:foo)[:key] = "another value"
      e['warden'].logout(:default)
      valid_response
    end
    setup_rack(app).call(@env)
    expect(@env['rack.session']['warden.user.default.session']).to be_nil
    expect(@env['rack.session']['warden.user.foo.session'    ]).to eq(key: "another value")
  end

  it "should clear out all data when a general logout is performed" do
    app = lambda do |e|
      e['warden'].session[:key] = "value"
      e['warden'].session(:foo)[:key] = "another value"
      e['warden'].logout
      valid_response
    end
    setup_rack(app).call(@env)
    expect(@env['rack.session']['warden.user.default.session']).to be_nil
    expect(@env['rack.session']['warden.user.foo.session'    ]).to be_nil
  end

  it "should logout multiple persons at once" do
    @env['rack.session']['warden.user.bar.key'] = "bar user"

    app = lambda do |e|
      e['warden'].session[:key] = "value"
      e['warden'].session(:foo)[:key] = "another value"
      e['warden'].session(:bar)[:key] = "yet another"
      e['warden'].logout(:bar, :default)
      valid_response
    end
    setup_rack(app).call(@env)
    expect(@env['rack.session']['warden.user.default.session']).to be_nil
    expect(@env['rack.session']['warden.user.foo.session'    ]).to eq(key: "another value")
    expect(@env['rack.session']['warden.user.bar.session'    ]).to be_nil
  end

  it "should not store data for a user who is not logged in" do
    @env['rack.session']
    app = lambda do |e|
      e['warden'].session(:not_here)[:key] = "value"
      valid_response
    end

    expect {
      setup_rack(app).call(@env)
    }.to raise_error(Warden::NotAuthenticated)
  end
end
