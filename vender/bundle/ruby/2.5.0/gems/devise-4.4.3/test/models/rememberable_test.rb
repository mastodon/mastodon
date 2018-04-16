# frozen_string_literal: true

require 'test_helper'

class RememberableTest < ActiveSupport::TestCase
  def resource_class
    User
  end

  def create_resource
    create_user
  end

  test 'remember_me should not generate a new token if using salt' do
    user = create_user
    user.expects(:valid?).never
    user.remember_me!
    assert user.remember_created_at
  end

  test 'remember_me should not generate a new token if valid token exists' do
    user = create_user
    user.singleton_class.send(:attr_accessor, :remember_token)
    User.to_adapter.expects(:find_first).returns(nil)

    user.remember_me!
    existing_token = user.remember_token

    user.remember_me!
    assert_equal existing_token, user.remember_token
  end

  test 'forget_me should not clear remember token if using salt' do
    user = create_user
    user.remember_me!
    user.expects(:valid?).never
    user.forget_me!
  end

  test 'can generate remember token' do
    user = create_user
    user.singleton_class.send(:attr_accessor, :remember_token)
    User.to_adapter.expects(:find_first).returns(nil)
    user.remember_me!
    assert user.remember_token
  end

  test 'serialize into cookie' do
    user = create_user
    user.remember_me!
    id, token, date = User.serialize_into_cookie(user)
    assert_equal id, user.to_key
    assert_equal token, user.authenticatable_salt
    assert date.is_a?(String)
  end

  test 'serialize from cookie' do
    user = create_user
    user.remember_me!
    assert_equal user, User.serialize_from_cookie(user.to_key, user.authenticatable_salt, Time.now.utc)
  end

  test 'serialize from cookie should accept a String with the datetime seconds and microseconds' do
    user = create_user
    user.remember_me!
    assert_equal user, User.serialize_from_cookie(user.to_key, user.authenticatable_salt, Time.now.utc.to_f.to_json)
  end

  test 'serialize from cookie should return nil with invalid datetime' do
    user = create_user
    user.remember_me!
    assert_nil User.serialize_from_cookie(user.to_key, user.authenticatable_salt, "2013")
  end

  test 'serialize from cookie should return nil if no resource is found' do
    assert_nil resource_class.serialize_from_cookie([0], "123", Time.now.utc)
  end

  test 'serialize from cookie should return nil if no timestamp' do
    user = create_user
    user.remember_me!
    assert_nil User.serialize_from_cookie(user.to_key, user.authenticatable_salt)
  end

  test 'serialize from cookie should return nil if timestamp is earlier than token creation' do
    user = create_user
    user.remember_me!
    assert_nil User.serialize_from_cookie(user.to_key, user.authenticatable_salt, 1.day.ago)
  end

  test 'serialize from cookie should return nil if timestamp is older than remember_for' do
    user = create_user
    user.remember_created_at = 1.month.ago
    user.remember_me!
    assert_nil User.serialize_from_cookie(user.to_key, user.authenticatable_salt, 3.weeks.ago)
  end

  test 'serialize from cookie me return nil if is a valid resource with invalid token' do
    user = create_user
    user.remember_me!
    assert_nil User.serialize_from_cookie(user.to_key, "123", Time.now.utc)
  end

  test 'raises a RuntimeError if the user does not implements a rememberable value' do
    user = User.new
    assert_raise(RuntimeError) { user.rememberable_value }

    user_with_remember_token = User.new
    def user_with_remember_token.remember_token; '123-token'; end
    assert_equal '123-token', user_with_remember_token.rememberable_value

    user_with_salt = User.new
    def user_with_salt.authenticatable_salt; '123-salt'; end
    assert_equal '123-salt', user_with_salt.rememberable_value
  end

  test 'raises a RuntimeError if authenticatable_salt is nil or empty' do
    user = User.new
    def user.authenticatable_salt; nil; end
    assert_raise RuntimeError do
      user.rememberable_value
    end

    user = User.new
    def user.authenticatable_salt; ""; end
    assert_raise RuntimeError do
      user.rememberable_value
    end
  end

  test 'should respond to remember_me attribute' do
    assert resource_class.new.respond_to?(:remember_me)
    assert resource_class.new.respond_to?(:remember_me=)
  end

  test 'forget_me should clear remember_created_at if expire_all_remember_me_on_sign_out is true' do
    swap Devise, expire_all_remember_me_on_sign_out: true do
      resource = create_resource
      resource.remember_me!
      assert_not_nil resource.remember_created_at

      resource.forget_me!
      assert_nil resource.remember_created_at
    end
  end

  test 'forget_me should not clear remember_created_at if expire_all_remember_me_on_sign_out is false' do
    swap Devise, expire_all_remember_me_on_sign_out: false do
      resource = create_resource
      resource.remember_me!

      assert_not_nil resource.remember_created_at

      resource.forget_me!
      assert_not_nil resource.remember_created_at
    end
  end

  test 'forget_me should not try to update resource if it has been destroyed' do
    resource = create_resource
    resource.expects(:remember_created_at).never
    resource.expects(:save).never

    resource.destroy
    resource.forget_me!
  end

  test 'remember expires at uses remember for configuration' do
    swap Devise, remember_for: 3.days do
      resource = create_resource
      resource.remember_me!
      assert_equal 3.days.from_now.to_date, resource.remember_expires_at.to_date

      Devise.remember_for = 5.days
      assert_equal 5.days.from_now.to_date, resource.remember_expires_at.to_date
    end
  end

  test 'should have the required_fields array' do
    assert_equal Devise::Models::Rememberable.required_fields(User), [
      :remember_created_at
    ]
  end
end
