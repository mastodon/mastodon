# encoding: utf-8
# frozen_string_literal: true
require 'spec_helper'

describe Warden::Config do

  before(:each) do
    @config = Warden::Config.new
  end

  it "should behave like a hash" do
    @config[:foo] = :bar
    expect(@config[:foo]).to eq(:bar)
  end

  it "should provide hash accessors" do
    @config.failure_app = :foo
    expect(@config[:failure_app]).to eq(:foo)
    @config[:failure_app] = :bar
    expect(@config.failure_app).to eq(:bar)
  end

  it "should allow to read and set default strategies" do
    @config.default_strategies :foo, :bar
    expect(@config.default_strategies).to eq([:foo, :bar])
  end

  it "should allow to silence missing strategies" do
    @config.silence_missing_strategies!
    expect(@config.silence_missing_strategies?).to eq(true)
  end

  it "should set the default_scope" do
    expect(@config.default_scope).to eq(:default)
    @config.default_scope = :foo
    expect(@config.default_scope).to eq(:foo)
  end

  it "should merge given options on initialization" do
    expect(Warden::Config.new(:foo => :bar)[:foo]).to eq(:bar)
  end

  it "should setup defaults with the scope_defaults method" do
    c = Warden::Config.new
    c.scope_defaults :foo, :strategies => [:foo, :bar], :store => false
    expect(c.default_strategies(:scope => :foo)).to eq([:foo, :bar])
    expect(c.scope_defaults(:foo)).to eq(store: false)
  end
end
