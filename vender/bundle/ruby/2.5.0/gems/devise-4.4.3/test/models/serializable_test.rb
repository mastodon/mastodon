# frozen_string_literal: true

require 'test_helper'

class SerializableTest < ActiveSupport::TestCase
  setup do
    @user = create_user
  end

  test 'should not include unsafe keys on XML' do
    assert_match(/email/, @user.to_xml)
    assert_no_match(/confirmation-token/, @user.to_xml)
  end

  test 'should not include unsafe keys on XML even if a new except is provided' do
    assert_no_match(/email/, @user.to_xml(except: :email))
    assert_no_match(/confirmation-token/, @user.to_xml(except: :email))
  end

  test 'should include unsafe keys on XML if a force_except is provided' do
    assert_no_match(/<email/, @user.to_xml(force_except: :email))
    assert_match(/confirmation-token/, @user.to_xml(force_except: :email))
  end

  test 'should not include unsafe keys on JSON' do
    keys = from_json().keys.select{ |key| !key.include?("id") }
    assert_equal %w(created_at email facebook_token updated_at username), keys.sort
  end

  test 'should not include unsafe keys on JSON even if a new except is provided' do
    assert_no_key "email", from_json(except: :email)
    assert_no_key "confirmation_token", from_json(except: :email)
  end

  test 'should include unsafe keys on JSON if a force_except is provided' do
    assert_no_key "email", from_json(force_except: :email)
    assert_key "confirmation_token", from_json(force_except: :email)
  end

  test 'should not include unsafe keys in inspect' do
    assert_match(/email/, @user.inspect)
    assert_no_match(/confirmation_token/, @user.inspect)
  end

  test 'should accept frozen options' do
    assert_key "username", @user.as_json({only: :username}.freeze)["user"]
  end

  def assert_key(key, subject)
    assert subject.key?(key), "Expected #{subject.inspect} to have key #{key.inspect}"
  end

  def assert_no_key(key, subject)
    assert !subject.key?(key), "Expected #{subject.inspect} to not have key #{key.inspect}"
  end

  def from_json(options=nil)
    ActiveSupport::JSON.decode(@user.to_json(options))["user"]
  end
end
