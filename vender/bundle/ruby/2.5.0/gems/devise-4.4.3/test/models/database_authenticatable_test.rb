# frozen_string_literal: true

require 'test_helper'
require 'test_models'
require 'digest/sha1'

class DatabaseAuthenticatableTest < ActiveSupport::TestCase
  def setup
    setup_mailer
  end

  test 'should downcase case insensitive keys when saving' do
    # case_insensitive_keys is set to :email by default.
    email = 'Foo@Bar.com'
    user = new_user(email: email)

    assert_equal email, user.email
    user.save!
    assert_equal email.downcase, user.email
  end

  test 'should downcase case insensitive keys that refer to virtual attributes when saving' do
    email        = 'Foo@Bar1.com'
    confirmation = 'Foo@Bar1.com'
    attributes   = valid_attributes(email: email, email_confirmation: confirmation)
    user = UserWithVirtualAttributes.new(attributes)

    assert_equal confirmation, user.email_confirmation
    user.save!
    assert_equal confirmation.downcase, user.email_confirmation
  end

  test 'should not mutate value assigned to case insensitive key' do
    email          = 'Foo@Bar.com'
    original_email = email.dup
    user           = new_user(email: email)

    user.save!
    assert_equal original_email, email
  end

  test 'should remove whitespace from strip whitespace keys when saving' do
    # strip_whitespace_keys is set to :email by default.
    email = ' foo@bar.com '
    user = new_user(email: email)

    assert_equal email, user.email
    user.save!
    assert_equal email.strip, user.email
  end

  test 'should not mutate value assigned to string whitespace key' do
    email          = ' foo@bar.com '
    original_email = email.dup
    user           = new_user(email: email)

    user.save!
    assert_equal original_email, email
  end

  test "doesn't throw exception when globally configured strip_whitespace_keys are not present on a model" do
    swap Devise, strip_whitespace_keys: [:fake_key] do
      assert_nothing_raised { create_user }
    end
  end

  test "doesn't throw exception when globally configured case_insensitive_keys are not present on a model" do
    swap Devise, case_insensitive_keys: [:fake_key] do
      assert_nothing_raised { create_user }
    end
  end

  test "param filter should not convert booleans and integer to strings" do
    conditions = { "login" => "foo@bar.com", "bool1" => true, "bool2" => false, "fixnum" => 123, "will_be_converted" => (1..10) }
    conditions = Devise::ParameterFilter.new([], []).filter(conditions)
    assert_equal( { "login" => "foo@bar.com", "bool1" => "true", "bool2" => "false", "fixnum" => "123", "will_be_converted" => "1..10" }, conditions)
  end

  test 'param filter should filter case_insensitive_keys as insensitive' do
    conditions = {'insensitive' => 'insensitive_VAL', 'sensitive' => 'sensitive_VAL'}
    conditions = Devise::ParameterFilter.new(['insensitive'], []).filter(conditions)
    assert_equal( {'insensitive' => 'insensitive_val', 'sensitive' => 'sensitive_VAL'}, conditions )
  end

  test 'param filter should filter strip_whitespace_keys stripping whitespaces' do
    conditions = {'strip_whitespace' => ' strip_whitespace_val ', 'do_not_strip_whitespace' => ' do_not_strip_whitespace_val '}
    conditions = Devise::ParameterFilter.new([], ['strip_whitespace']).filter(conditions)
    assert_equal( {'strip_whitespace' => 'strip_whitespace_val', 'do_not_strip_whitespace' => ' do_not_strip_whitespace_val '}, conditions )
  end

  test 'should respond to password and password confirmation' do
    user = new_user
    assert user.respond_to?(:password)
    assert user.respond_to?(:password_confirmation)
  end

  test 'should generate a hashed password while setting password' do
    user = new_user
    assert_present user.encrypted_password
  end

  test 'should support custom hashing methods' do
    user = UserWithCustomHashing.new(password: '654321')
    assert_equal user.encrypted_password, '123456'
  end

  test 'allow authenticatable_salt to work even with nil hashed password' do
    user = User.new
    user.encrypted_password = nil
    assert_nil user.authenticatable_salt
  end

  test 'should not generate a hashed password if password is blank' do
    assert_blank new_user(password: nil).encrypted_password
    assert_blank new_user(password: '').encrypted_password
  end

  test 'should hash password again if password has changed' do
    user = create_user
    encrypted_password = user.encrypted_password
    user.password = user.password_confirmation = 'new_password'
    user.save!
    assert_not_equal encrypted_password, user.encrypted_password
  end

  test 'should test for a valid password' do
    user = create_user
    assert user.valid_password?('12345678')
    refute user.valid_password?('654321')
  end

  test 'should not raise error with an empty password' do
    user = create_user
    user.encrypted_password = ''
    assert_nothing_raised { user.valid_password?('12345678') }
  end

  test 'should be an invalid password if the user has an empty password' do
    user = create_user
    user.encrypted_password = ''
    refute user.valid_password?('654321')
  end

  test 'should respond to current password' do
    assert new_user.respond_to?(:current_password)
  end

  test 'should update password with valid current password' do
    user = create_user
    assert user.update_with_password(current_password: '12345678',
      password: 'pass4321', password_confirmation: 'pass4321')
    assert user.reload.valid_password?('pass4321')
  end

  test 'should add an error to current password when it is invalid' do
    user = create_user
    refute user.update_with_password(current_password: 'other',
      password: 'pass4321', password_confirmation: 'pass4321')
    assert user.reload.valid_password?('12345678')
    assert_match "is invalid", user.errors[:current_password].join
  end

  test 'should add an error to current password when it is blank' do
    user = create_user
    refute user.update_with_password(password: 'pass4321',
      password_confirmation: 'pass4321')
    assert user.reload.valid_password?('12345678')
    assert_match "can't be blank", user.errors[:current_password].join
  end

  test 'should run validations even when current password is invalid or blank' do
    user = UserWithValidation.create!(valid_attributes)
    user.save
    assert user.persisted?
    refute user.update_with_password(username: "")
    assert_match "usertest", user.reload.username
    assert_match "can't be blank", user.errors[:username].join
  end

  test 'should ignore password and its confirmation if they are blank' do
    user = create_user
    assert user.update_with_password(current_password: '12345678', email: "new@example.com")
    assert_equal "new@example.com", user.email
  end

  test 'should not update password with invalid confirmation' do
    user = create_user
    refute user.update_with_password(current_password: '12345678',
      password: 'pass4321', password_confirmation: 'other')
    assert user.reload.valid_password?('12345678')
  end

  test 'should clean up password fields on failure' do
    user = create_user
    refute user.update_with_password(current_password: '12345678',
      password: 'pass4321', password_confirmation: 'other')
    assert user.password.blank?
    assert user.password_confirmation.blank?
  end

  test 'should update the user without password' do
    user = create_user
    user.update_without_password(email: 'new@example.com')
    assert_equal 'new@example.com', user.email
  end

  test 'should not update password without password' do
    user = create_user
    user.update_without_password(password: 'pass4321', password_confirmation: 'pass4321')
    assert !user.reload.valid_password?('pass4321')
    assert user.valid_password?('12345678')
  end

  test 'should destroy user if current password is valid' do
    user = create_user
    assert user.destroy_with_password('12345678')
    assert !user.persisted?
  end

  test 'should not destroy user with invalid password' do
    user = create_user
    refute user.destroy_with_password('other')
    assert user.persisted?
    assert_match "is invalid", user.errors[:current_password].join
  end

  test 'should not destroy user with blank password' do
    user = create_user
    refute user.destroy_with_password(nil)
    assert user.persisted?
    assert_match "can't be blank", user.errors[:current_password].join
  end

  test 'should not email on password change' do
    user = create_user
    assert_email_not_sent do
      assert user.update_attributes(password: 'newpass', password_confirmation: 'newpass')
    end
  end

  test 'should notify previous email on email change when configured' do
    swap Devise, send_email_changed_notification: true do
      user = create_user
      original_email = user.email
      assert_email_sent original_email do
        assert user.update_attributes(email: 'new-email@example.com')
      end
      assert_match original_email, ActionMailer::Base.deliveries.last.body.encoded
    end
  end

  test 'should notify email on password change when configured' do
    swap Devise, send_password_change_notification: true do
      user = create_user
      assert_email_sent user.email do
        assert user.update_attributes(password: 'newpass', password_confirmation: 'newpass')
      end
      assert_match user.email, ActionMailer::Base.deliveries.last.body.encoded
    end
  end

  test 'downcase_keys with validation' do
    User.create(email: "HEllO@example.com", password: "123456")
    user = User.create(email: "HEllO@example.com", password: "123456")
    assert !user.valid?
  end

  test 'required_fields should be encryptable_password and the email field by default' do
    assert_equal Devise::Models::DatabaseAuthenticatable.required_fields(User), [
      :encrypted_password,
      :email
    ]
  end

  test 'required_fields should be encryptable_password and the login when the login is on authentication_keys' do
    swap Devise, authentication_keys: [:login] do
      assert_equal Devise::Models::DatabaseAuthenticatable.required_fields(User), [
        :encrypted_password,
        :login
      ]
    end
  end
end
