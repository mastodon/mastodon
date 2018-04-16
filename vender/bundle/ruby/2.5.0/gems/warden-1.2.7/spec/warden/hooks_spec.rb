# encoding: utf-8
# frozen_string_literal: true
require 'spec_helper'

describe "standard authentication hooks" do

  before(:all) do
    load_strategies
  end

  describe "after_set_user" do
    before(:each) do
      RAM = Warden::Manager unless defined?(RAM)
      RAM._after_set_user.clear
    end

    after(:each) do
      RAM._after_set_user.clear
    end

    it "should allow me to add an after_set_user hook" do
      RAM.after_set_user do |user, auth, opts|
        "boo"
      end
      expect(RAM._after_set_user.length).to eq(1)
    end

    it "should allow me to add multiple after_set_user hooks" do
      RAM.after_set_user{|user, auth, opts| "foo"}
      RAM.after_set_user{|u,a| "bar"}
      expect(RAM._after_set_user.length).to eq(2)
    end

    it "should run each after_set_user hook after the user is set" do
      RAM.after_set_user{|u,a,o| a.env['warden.spec.hook.foo'] = "run foo"}
      RAM.after_set_user{|u,a,o| a.env['warden.spec.hook.bar'] = "run bar"}
      RAM.after_set_user{|u,a,o| a.logout}
      app = lambda do |e|
        e['warden'].set_user("foo")
        valid_response
      end
      env = env_with_params
      setup_rack(app).call(env)
      expect(env['warden'].user).to be_nil
      expect(env['warden.spec.hook.foo']).to eq("run foo")
      expect(env['warden.spec.hook.bar']).to eq("run bar")
    end

    it "should not run the event specified with except" do
      RAM.after_set_user(:except => :set_user){|u,a,o| fail}
      app = lambda do |e|
        e['warden'].set_user("foo")
        valid_response
      end
      env = env_with_params
      setup_rack(app).call(env)
    end

    it "should only run the event specified with only" do
      RAM.after_set_user(:only => :set_user){|u,a,o| fail}
      app = lambda do |e|
        e['warden'].authenticate(:pass)
        valid_response
      end
      env = env_with_params
      setup_rack(app).call(env)
    end

    it "should run filters in the given order" do
      RAM.after_set_user{|u,a,o| a.env['warden.spec.order'] << 2}
      RAM.after_set_user{|u,a,o| a.env['warden.spec.order'] << 3}
      RAM.prepend_after_set_user{|u,a,o| a.env['warden.spec.order'] << 1}
      app = lambda do |e|
        e['warden.spec.order'] = []
        e['warden'].set_user("foo")
        valid_response
      end
      env = env_with_params
      setup_rack(app).call(env)
      expect(env['warden.spec.order']).to eq([1,2,3])
    end

    context "after_authentication" do
      it "should be a wrapper to after_set_user behavior" do
        RAM.after_authentication{|u,a,o| a.env['warden.spec.hook.baz'] = "run baz"}
        RAM.after_authentication{|u,a,o| a.env['warden.spec.hook.paz'] = "run paz"}
        RAM.after_authentication{|u,a,o| expect(o[:event]).to eq(:authentication) }
        app = lambda do |e|
          e['warden'].authenticate(:pass)
          valid_response
        end
        env = env_with_params
        setup_rack(app).call(env)
        expect(env['warden.spec.hook.baz']).to eq('run baz')
        expect(env['warden.spec.hook.paz']).to eq('run paz')
      end

      it "should not be invoked on default after_set_user scenario" do
        RAM.after_authentication{|u,a,o| fail}
        app = lambda do |e|
          e['warden'].set_user("foo")
          valid_response
        end
        env = env_with_params
        setup_rack(app).call(env)
      end

      it "should run filters in the given order" do
        RAM.after_authentication{|u,a,o| a.env['warden.spec.order'] << 2}
        RAM.after_authentication{|u,a,o| a.env['warden.spec.order'] << 3}
        RAM.prepend_after_authentication{|u,a,o| a.env['warden.spec.order'] << 1}
        app = lambda do |e|
          e['warden.spec.order'] = []
          e['warden'].authenticate(:pass)
          valid_response
        end
        env = env_with_params
        setup_rack(app).call(env)
        expect(env['warden.spec.order']).to eq([1,2,3])
      end

      it "should allow me to log out a user in an after_set_user block" do
        RAM.after_set_user{|u,a,o| a.logout}

        app = lambda do |e|
          e['warden'].authenticate(:pass)
          valid_response
        end
        env = env_with_params
        setup_rack(app).call(env)
        expect(env['warden']).not_to be_authenticated
      end
    end

    context "after_fetch" do
      it "should be a wrapper to after_set_user behavior" do
        RAM.after_fetch{|u,a,o| a.env['warden.spec.hook.baz'] = "run baz"}
        RAM.after_fetch{|u,a,o| a.env['warden.spec.hook.paz'] = "run paz"}
        RAM.after_fetch{|u,a,o| expect(o[:event]).to eq(:fetch) }
        env = env_with_params
        setup_rack(lambda { |e| valid_response }).call(env)
        env['rack.session']['warden.user.default.key'] = "Foo"
        expect(env['warden'].user).to eq("Foo")
        expect(env['warden.spec.hook.baz']).to eq('run baz')
        expect(env['warden.spec.hook.paz']).to eq('run paz')
      end

      it "should not be invoked on default after_set_user scenario" do
        RAM.after_fetch{|u,a,o| fail}
        app = lambda do |e|
          e['warden'].set_user("foo")
          valid_response
        end
        env = env_with_params
        setup_rack(app).call(env)
      end

      it "should not be invoked if fetched user is nil" do
        RAM.after_fetch{|u,a,o| fail}
        env = env_with_params
        setup_rack(lambda { |e| valid_response }).call(env)
        env['rack.session']['warden.user.default.key'] = nil
        expect(env['warden'].user).to be_nil
      end

      it "should run filters in the given order" do
        RAM.after_fetch{|u,a,o| a.env['warden.spec.order'] << 2}
        RAM.after_fetch{|u,a,o| a.env['warden.spec.order'] << 3}
        RAM.prepend_after_fetch{|u,a,o| a.env['warden.spec.order'] << 1}
        app = lambda do |e|
          e['warden.spec.order'] = []
          e['rack.session']['warden.user.default.key'] = "Foo"
          e['warden'].user
          valid_response
        end
        env = env_with_params
        setup_rack(app).call(env)
        expect(env['warden.spec.order']).to eq([1,2,3])
      end
    end
  end


  describe "after_failed_fetch" do
    before(:each) do
      RAM = Warden::Manager unless defined?(RAM)
      RAM._after_failed_fetch.clear
    end

    after(:each) do
      RAM._after_failed_fetch.clear
    end

    it "should not be called when user is fetched" do
      RAM.after_failed_fetch{|u,a,o| fail }
      env = env_with_params
      setup_rack(lambda { |e| valid_response }).call(env)
      env['rack.session']['warden.user.default.key'] = "Foo"
      expect(env['warden'].user).to eq("Foo")
    end

    it "should be called if fetched user is nil" do
      calls = 0
      RAM.after_failed_fetch{|u,a,o| calls += 1 }
      env = env_with_params
      setup_rack(lambda { |e| valid_response }).call(env)
      expect(env['warden'].user).to be_nil
      expect(calls).to eq(1)
    end
  end

  describe "before_failure" do
    before(:each) do
      RAM = Warden::Manager unless defined?(RAM)
      RAM._before_failure.clear
    end

    after(:each) do
      RAM._before_failure.clear
    end

    it "should allow me to add a before_failure hook" do
      RAM.before_failure{|env, opts| "foo"}
      expect(RAM._before_failure.length).to eq(1)
    end

    it "should allow me to add multiple before_failure hooks" do
      RAM.before_failure{|env, opts| "foo"}
      RAM.before_failure{|env, opts| "bar"}
      expect(RAM._before_failure.length).to eq(2)
    end

    it "should run each before_failure hooks before failing" do
      RAM.before_failure{|e,o| e['warden.spec.before_failure.foo'] = "foo"}
      RAM.before_failure{|e,o| e['warden.spec.before_failure.bar'] = "bar"}
      app = lambda{|e| e['warden'].authenticate!(:failz); valid_response}
      env = env_with_params
      setup_rack(app).call(env)
      expect(env['warden.spec.before_failure.foo']).to eq("foo")
      expect(env['warden.spec.before_failure.bar']).to eq("bar")
    end

    it "should run filters in the given order" do
      RAM.before_failure{|e,o| e['warden.spec.order'] << 2}
      RAM.before_failure{|e,o| e['warden.spec.order'] << 3}
      RAM.prepend_before_failure{|e,o| e['warden.spec.order'] << 1}
      app = lambda do |e|
        e['warden.spec.order'] = []
        e['warden'].authenticate!(:failz)
        valid_response
      end
      env = env_with_params
      setup_rack(app).call(env)
      expect(env['warden.spec.order']).to eq([1,2,3])
    end
  end

  describe "before_logout" do
    before(:each) do
      RAM = Warden::Manager unless defined?(RAM)
      RAM._before_logout.clear
    end

    after(:each) do
      RAM._before_logout.clear
    end

    it "should allow me to add an before_logout hook" do
      RAM.before_logout{|user, auth, scopes| "foo"}
      expect(RAM._before_logout.length).to eq(1)
    end

    it "should allow me to add multiple after_authentication hooks" do
      RAM.before_logout{|u,a,o| "bar"}
      RAM.before_logout{|u,a,o| "baz"}
      expect(RAM._before_logout.length).to eq(2)
    end

    it "should run each before_logout hook before logout is run" do
      RAM.before_logout{|u,a,o| a.env['warden.spec.hook.lorem'] = "run lorem"}
      RAM.before_logout{|u,a,o| a.env['warden.spec.hook.ipsum'] = "run ipsum"}
      app = lambda{|e| e['warden'].authenticate(:pass); valid_response}
      env = env_with_params
      setup_rack(app).call(env)
      env['warden'].logout
      expect(env['warden.spec.hook.lorem']).to eq('run lorem')
      expect(env['warden.spec.hook.ipsum']).to eq('run ipsum')
    end

    it "should run before_logout hook for a specified scope" do
      RAM.before_logout(:scope => :scope1){|u,a,o| a.env["warden.spec.hook.a"] << :scope1 }
      RAM.before_logout(:scope => [:scope2]){|u,a,o| a.env["warden.spec.hook.b"] << :scope2 }

      app = lambda do |e|
        e['warden'].authenticate(:pass, :scope => :scope1)
        e['warden'].authenticate(:pass, :scope => :scope2)
        valid_response
      end
      env = env_with_params
      env["warden.spec.hook.a"] ||= []
      env["warden.spec.hook.b"] ||= []
      setup_rack(app).call(env)

      env['warden'].logout(:scope1)
      expect(env['warden.spec.hook.a']).to eq([:scope1])
      expect(env['warden.spec.hook.b']).to eq([])

      env['warden'].logout(:scope2)
      expect(env['warden.spec.hook.a']).to eq([:scope1])
      expect(env['warden.spec.hook.b']).to eq([:scope2])
    end

    it "should run filters in the given order" do
      RAM.before_logout{|u,a,o| a.env['warden.spec.order'] << 2}
      RAM.before_logout{|u,a,o| a.env['warden.spec.order'] << 3}
      RAM.prepend_before_logout{|u,a,o| a.env['warden.spec.order'] << 1}
      app = lambda do |e|
        e['warden.spec.order'] = []
        e['warden'].authenticate(:pass)
        e['warden'].logout
        valid_response
      end
      env = env_with_params
      setup_rack(app).call(env)
      expect(env['warden.spec.order']).to eq([1,2,3])
    end
  end

  describe "on_request" do
    before(:each) do
      RAM = Warden::Manager unless defined?(RAM)
      @old_on_request = RAM._on_request.dup
      RAM._on_request.clear
    end

    after(:each) do
      RAM._on_request.clear
      RAM._on_request.replace(@old_on_request)
    end

    it "should allow me to add an on_request hook" do
      RAM.on_request{|proxy| "foo"}
      expect(RAM._on_request.length).to eq(1)
    end

    it "should allow me to add multiple on_request hooks" do
      RAM.on_request{|proxy| "foo"}
      RAM.on_request{|proxy| "bar"}
      expect(RAM._on_request.length).to eq(2)
    end

    it "should run each on_request hooks when initializing" do
      RAM.on_request{|proxy| proxy.env['warden.spec.on_request.foo'] = "foo"}
      RAM.on_request{|proxy| proxy.env['warden.spec.on_request.bar'] = "bar"}
      app = lambda{|e| valid_response}
      env = env_with_params
      setup_rack(app).call(env)
      expect(env['warden.spec.on_request.foo']).to eq("foo")
      expect(env['warden.spec.on_request.bar']).to  eq("bar")
    end

    it "should run filters in the given order" do
      RAM.on_request{|proxy| proxy.env['warden.spec.order'] << 2}
      RAM.on_request{|proxy| proxy.env['warden.spec.order'] << 3}
      RAM.prepend_on_request{|proxy| proxy.env['warden.spec.order'] << 1}
      app = lambda do |e|
        valid_response
      end
      env = Rack::MockRequest.env_for("/", "warden.spec.order" => [])
      setup_rack(app).call(env)
      expect(env['warden.spec.order']).to eq([1,2,3])
    end
  end
end
