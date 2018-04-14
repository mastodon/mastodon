# frozen_string_literal: true

require 'test_helper'

module Devise
  def self.yield_and_restore
    @@warden_configured = nil
    c, b = @@warden_config, @@warden_config_blocks
    yield
  ensure
    @@warden_config, @@warden_config_blocks = c, b
  end
end

class DeviseTest < ActiveSupport::TestCase
  test 'bcrypt on the class' do
    password = "super secret"
    klass    = Struct.new(:pepper, :stretches).new("blahblah", 2)
    hash     = Devise::Encryptor.digest(klass, password)
    assert_equal ::BCrypt::Password.create(hash), hash

    klass    = Struct.new(:pepper, :stretches).new("bla", 2)
    hash     = Devise::Encryptor.digest(klass, password)
    assert_not_equal ::BCrypt::Password.new(hash), hash
  end

  test 'model options can be configured through Devise' do
    swap Devise, allow_unconfirmed_access_for: 113, pepper: "foo" do
      assert_equal 113, Devise.allow_unconfirmed_access_for
      assert_equal "foo", Devise.pepper
    end
  end

  test 'setup block yields self' do
    Devise.setup do |config|
      assert_equal Devise, config
    end
  end

  test 'stores warden configuration' do
    assert_kind_of Devise::Delegator, Devise.warden_config.failure_app
    assert_equal :user, Devise.warden_config.default_scope
  end

  test 'warden manager user configuration through a block' do
    Devise.yield_and_restore do
      executed = false
      Devise.warden do |config|
        executed = true
        assert_kind_of Warden::Config, config
      end

      Devise.configure_warden!
      assert executed
    end
  end

  test 'warden manager user configuration through multiple blocks' do
    Devise.yield_and_restore do
      executed = 0

      3.times do
        Devise.warden { |config| executed += 1 }
      end

      Devise.configure_warden!
      assert_equal 3, executed
    end
  end

  test 'add new module using the helper method' do
    Devise.add_module(:coconut)
    assert_equal 1, Devise::ALL.select { |v| v == :coconut }.size
    refute Devise::STRATEGIES.include?(:coconut)
    refute defined?(Devise::Models::Coconut)
    Devise::ALL.delete(:coconut)

    Devise.add_module(:banana, strategy: :fruits)
    assert_equal :fruits, Devise::STRATEGIES[:banana]
    Devise::ALL.delete(:banana)
    Devise::STRATEGIES.delete(:banana)

    Devise.add_module(:kivi, controller: :fruits)
    assert_equal :fruits, Devise::CONTROLLERS[:kivi]
    Devise::ALL.delete(:kivi)
    Devise::CONTROLLERS.delete(:kivi)
  end

  test 'should complain when comparing empty or different sized passes' do
    [nil, ""].each do |empty|
      refute Devise.secure_compare(empty, "something")
      refute Devise.secure_compare("something", empty)
      refute Devise.secure_compare(empty, empty)
    end
    refute Devise.secure_compare("size_1", "size_four")
  end

  test 'Devise.email_regexp should match valid email addresses' do
    valid_emails = ["test@example.com", "jo@jo.co", "f4$_m@you.com", "testing.example@example.com.ua", "test@tt", "test@valid---domain.com"]
    non_valid_emails = ["rex", "test user@example.com", "test_user@example server.com"]

    valid_emails.each do |email|
      assert_match Devise.email_regexp, email
    end
    non_valid_emails.each do |email|
      assert_no_match Devise.email_regexp, email
    end
  end
end
