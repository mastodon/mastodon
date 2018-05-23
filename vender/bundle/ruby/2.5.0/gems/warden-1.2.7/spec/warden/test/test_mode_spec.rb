# encoding: utf-8
# frozen_string_literal: true
require 'spec_helper'

describe Warden::Test::WardenHelpers do
  before :all do
    Warden.test_mode!
  end

  before do
    $captures = []
    @app = lambda{|e| valid_response }
  end

  after do
    Warden.test_reset!
  end

  it{ expect(Warden).to respond_to(:test_mode!)       }
  it{ expect(Warden).to respond_to(:on_next_request)  }
  it{ expect(Warden).to respond_to(:test_reset!)      }

  it "should execute the on_next_request block on the next request" do
    Warden.on_next_request do |warden|
      $captures << warden
    end

    setup_rack(@app).call(env_with_params)
    expect($captures.length).to eq(1)
    expect($captures.first).to be_an_instance_of(Warden::Proxy)
  end

  it "should execute many on_next_request blocks on the next request" do
    Warden.on_next_request{|w| $captures << :first    }
    Warden.on_next_request{|w| $captures << :second   }
    setup_rack(@app).call(env_with_params)
    expect($captures).to eq([:first, :second])
  end

  it "should not execute on_next_request blocks on subsequent requests" do
    app = setup_rack(@app)
    Warden.on_next_request{|w| $captures << :first }
    app.call(env_with_params)
    expect($captures).to eq([:first])
    $captures.clear
    app.call(env_with_params)
    expect($captures).to be_empty
  end

  it "should allow me to set new_on_next_request items to execute in the same test" do
    app = setup_rack(@app)
    Warden.on_next_request{|w| $captures << :first }
    app.call(env_with_params)
    expect($captures).to eq([:first])
    Warden.on_next_request{|w| $captures << :second }
    app.call(env_with_params)
    expect($captures).to eq([:first, :second])
  end

  it "should remove the on_next_request items when test is reset" do
    app = setup_rack(@app)
    Warden.on_next_request{|w| $captures << :first }
    Warden.test_reset!
    app.call(env_with_params)
    expect($captures).to eq([])
  end

  context "asset requests" do
    it "should not execute on_next_request blocks if this is an asset request" do
      app = setup_rack(@app)
      Warden.on_next_request{|w| $captures << :first }
      app.call(env_with_params("/assets/fun.gif"))
      expect($captures).to eq([])
    end
  end
end
