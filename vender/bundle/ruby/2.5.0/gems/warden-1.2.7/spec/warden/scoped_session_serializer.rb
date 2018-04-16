# encoding: utf-8
# frozen_string_literal: true
require 'spec_helper'

describe Warden::Manager do
  before(:each) do
    @env = env_with_params
    @env['rack.session'] ||= {}
    Warden::Manager.serialize_from_session { |k| k }
    Warden::Manager.serialize_into_session { |u| u }
    begin
      Warden::SessionSerializer.send :remove_method, :admin_serialize
    rescue
    end
    begin
      Warden::SessionSerializer.send :remove_method, :admin_deserialize
    rescue
    end
  end
  after(:each) do
    Warden::Manager.serialize_from_session { |k| k }
    Warden::Manager.serialize_into_session { |u| u }
    begin
      Warden::SessionSerializer.send :remove_method, :admin_deserialize
      Warden::SessionSerializer.send :remove_method, :admin_serialize
    rescue
    end
  end

  def serializer_respond_to?(name)
    Warden::SessionSerializer.new(@env).respond_to? name
  end

  it "should respond to :serialize" do
    serializer_respond_to?(:serialize).should be_true
  end

  it "should respond to :deserialize" do
    serializer_respond_to?(:deserialize).should be_true
  end

  it "should respond to {scope}_deserialize if Manager.serialize_from_session is called with scope" do
    Rack::Builder.new do 
      Warden::Manager.serialize_from_session ( :admin ) { |n| n }
    end
    serializer_respond_to?(:admin_deserialize).should be_true
  end

  it "should respond to {scope}_serialize if Manager.serialize_into_session is called with scope" do
    Rack::Builder.new do 
      Warden::Manager.serialize_into_session(:admin) { |n| n }
    end
    serializer_respond_to?(:admin_serialize).should be_true
  end

  def initialize_with_scope(scope, &block)
    Rack::Builder.new do
      Warden::Manager.serialize_into_session(scope, &block)
    end
  end

  it "should execute serialize if no {scope}_serialize is present" do
    serialized_object = nil
    initialize_with_scope(nil) do |user|
      serialized_object = user
      user
    end
    serializer = Warden::SessionSerializer.new(@env)
    serializer.store("user", :admin)
    serialized_object.should eq("user")
  end

  it "should not have a {scope}_serialize by default" do
    serializer_respond_to?(:admin_serialize).should be_false
  end

  it "should execute {scope}_serialize when calling store with a scope" do
    serialized_object = nil
    initialize_with_scope(:admin) do |user|
      serialized_object = user
      user
    end

    serializer = Warden::SessionSerializer.new(@env)
    serializer.store("user", :admin)
    serialized_object.should eq("user")
  end


  it "should execute {scope}_deserialize when calling store with a scope" do
    serialized_object = nil

    Rack::Builder.new do
      Warden::Manager.serialize_from_session(:admin) do |key|
        serialized_object = key
        key
      end
    end

    serializer = Warden::SessionSerializer.new(@env)
    @env['rack.session'][serializer.key_for(:admin)] = "test"
    serializer.fetch(:admin)

    serialized_object.should eq("test")
  end

  it "should execute deserialize if {scope}_deserialize is not present" do
    serialized_object = nil

    Rack::Builder.new do
      Warden::Manager.serialize_from_session do |key|
        serialized_object = key
        key
      end
    end

    serializer = Warden::SessionSerializer.new(@env)
    @env['rack.session'][serializer.key_for(:admin)] = "test"
    serializer.fetch(:admin)

    serialized_object.should eq("test")
  end

end
