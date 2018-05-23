# encoding: utf-8
# frozen_string_literal: true
require 'spec_helper'

describe Warden::Test::Helpers do
  before{ $captures = [] }
  after{ Warden.test_reset! }

  it "should log me in as a user" do
    user = "A User"
    login_as user
    app = lambda{|e|
      $captures << :run
      expect(e['warden']).to be_authenticated
      expect(e['warden'].user).to eq("A User")
      valid_response
    }
    setup_rack(app).call(env_with_params)
    expect($captures).to eq([:run])
  end

  it "should log me in as a user of a given scope" do
    user = {:some => "user"}
    login_as user, :scope => :foo_scope
    app = lambda{|e|
      $captures << :run
      w = e['warden']
      expect(w).to be_authenticated(:foo_scope)
      expect(w.user(:foo_scope)).to eq(some: "user")
    }
    setup_rack(app).call(env_with_params)
    expect($captures).to eq([:run])
  end

  it "should login multiple users with different scopes" do
    user      = "A user"
    foo_user  = "A foo user"
    login_as user
    login_as foo_user, :scope => :foo
    app = lambda{|e|
      $captures << :run
      w = e['warden']
      expect(w.user).to eq("A user")
      expect(w.user(:foo)).to eq("A foo user")
      expect(w).to be_authenticated
      expect(w).to be_authenticated(:foo)
    }
    setup_rack(app).call(env_with_params)
    expect($captures).to eq([:run])
  end

  it "should log out all users" do
    user = "A user"
    foo  = "Foo"
    login_as user
    login_as foo, :scope => :foo
    app = lambda{|e|
      $captures << :run
      w = e['warden']
      expect(w.user).to eq("A user")
      expect(w.user(:foo)).to eq("Foo")
      w.logout
      expect(w.user).to be_nil
      expect(w.user(:foo)).to be_nil
      expect(w).not_to be_authenticated
      expect(w).not_to be_authenticated(:foo)
    }
    setup_rack(app).call(env_with_params)
    expect($captures).to eq([:run])
  end

  it "should logout a specific user" do
    user = "A User"
    foo  = "Foo"
    login_as user
    login_as foo, :scope => :foo
    app = lambda{|e|
      $captures << :run
      w = e['warden']
      w.logout :foo
      expect(w.user).to eq("A User")
      expect(w.user(:foo)).to be_nil
      expect(w).not_to be_authenticated(:foo)
    }
    setup_rack(app).call(env_with_params)
    expect($captures).to eq([:run])
  end

  describe "#asset_paths" do
    it "should default asset_paths to anything asset path regex" do
      expect(Warden.asset_paths).to eq([/^\/assets\//]      )
    end
  end
end
