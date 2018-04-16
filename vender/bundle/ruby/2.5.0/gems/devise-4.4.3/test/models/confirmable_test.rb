# frozen_string_literal: true

require 'test_helper'

class ConfirmableTest < ActiveSupport::TestCase

  def setup
    setup_mailer
  end

  test 'should set callbacks to send the mail' do
    if DEVISE_ORM == :active_record
      defined_callbacks = User._commit_callbacks.map(&:filter)
      assert_includes defined_callbacks, :send_on_create_confirmation_instructions
      assert_includes defined_callbacks, :send_reconfirmation_instructions
    elsif DEVISE_ORM == :mongoid
      assert_includes User._create_callbacks.map(&:filter), :send_on_create_confirmation_instructions
      assert_includes User._update_callbacks.map(&:filter), :send_reconfirmation_instructions
    end
  end

  test 'should generate confirmation token after creating a record' do
    assert_nil new_user.confirmation_token
    assert_not_nil create_user.confirmation_token
  end

  test 'should never generate the same confirmation token for different users' do
    confirmation_tokens = []
    3.times do
      token = create_user.confirmation_token
      assert !confirmation_tokens.include?(token)
      confirmation_tokens << token
    end
  end

  test 'should confirm a user by updating confirmed at' do
    user = create_user
    assert_nil user.confirmed_at
    assert user.confirm
    assert_not_nil user.confirmed_at
  end

  test 'should verify whether a user is confirmed or not' do
    refute new_user.confirmed?
    user = create_user
    refute user.confirmed?
    user.confirm
    assert user.confirmed?
  end

  test 'should not confirm a user already confirmed' do
    user = create_user
    assert user.confirm
    assert_blank user.errors[:email]

    refute user.confirm
    assert_equal "was already confirmed, please try signing in", user.errors[:email].join
  end

  test 'should find and confirm a user automatically based on the raw token' do
    user = create_user
    raw  = user.raw_confirmation_token
    confirmed_user = User.confirm_by_token(raw)
    assert_equal confirmed_user, user
    assert user.reload.confirmed?
  end

  test 'should return a new record with errors when a invalid token is given' do
    confirmed_user = User.confirm_by_token('invalid_confirmation_token')
    refute confirmed_user.persisted?
    assert_equal "is invalid", confirmed_user.errors[:confirmation_token].join
  end

  test 'should return a new record with errors when a blank token is given' do
    confirmed_user = User.confirm_by_token('')
    refute confirmed_user.persisted?
    assert_equal "can't be blank", confirmed_user.errors[:confirmation_token].join
  end

  test 'should generate errors for a user email if user is already confirmed' do
    user = create_user
    user.confirmed_at = Time.now
    user.save
    confirmed_user = User.confirm_by_token(user.raw_confirmation_token)
    assert confirmed_user.confirmed?
    assert_equal "was already confirmed, please try signing in", confirmed_user.errors[:email].join
  end

  test 'should show error when a token has already been used' do
    user = create_user
    raw  = user.raw_confirmation_token
    User.confirm_by_token(raw)
    assert user.reload.confirmed?

    confirmed_user = User.confirm_by_token(raw)
    assert_equal "was already confirmed, please try signing in", confirmed_user.errors[:email].join
  end

  test 'should send confirmation instructions by email' do
    assert_email_sent "mynewuser@example.com" do
      create_user email: "mynewuser@example.com"
    end
  end

  test 'should not send confirmation when trying to save an invalid user' do
    assert_email_not_sent do
      user = new_user
      user.stubs(:valid?).returns(false)
      user.save
    end
  end

  test 'should not generate a new token neither send e-mail if skip_confirmation! is invoked' do
    user = new_user
    user.skip_confirmation!

    assert_email_not_sent do
      user.save!
      assert_nil user.confirmation_token
      assert_not_nil user.confirmed_at
    end
  end

  test 'should skip confirmation e-mail without confirming if skip_confirmation_notification! is invoked' do
    user = new_user
    user.skip_confirmation_notification!

    assert_email_not_sent do
      user.save!
      refute user.confirmed?
    end
  end

  test 'should not send confirmation when no email is provided' do
    assert_email_not_sent do
      user = new_user
      user.email = ''
      user.save(validate: false)
    end
  end

  test 'should find a user to send confirmation instructions' do
    user = create_user
    confirmation_user = User.send_confirmation_instructions(email: user.email)
    assert_equal confirmation_user, user
  end

  test 'should return a new user if no email was found' do
    confirmation_user = User.send_confirmation_instructions(email: "invalid@example.com")
    refute confirmation_user.persisted?
  end

  test 'should add error to new user email if no email was found' do
    confirmation_user = User.send_confirmation_instructions(email: "invalid@example.com")
    assert confirmation_user.errors[:email]
    assert_equal "not found", confirmation_user.errors[:email].join
  end

  test 'should send email instructions for the user confirm its email' do
    user = create_user
    assert_email_sent user.email do
      User.send_confirmation_instructions(email: user.email)
    end
  end

  test 'should always have confirmation token when email is sent' do
    user = new_user
    user.instance_eval { def confirmation_required?; false end }
    user.save
    user.send_confirmation_instructions
    assert_not_nil user.reload.confirmation_token
  end

  test 'should not resend email instructions if the user change their email' do
    user = create_user
    user.email = 'new_test@example.com'
    assert_email_not_sent do
      user.save!
    end
  end

  test 'should not reset confirmation status or token when updating email' do
    user = create_user
    original_token = user.confirmation_token
    user.confirm
    user.email = 'new_test@example.com'
    user.save!

    user.reload
    assert user.confirmed?
    assert_equal original_token, user.confirmation_token
  end

  test 'should not be able to send instructions if the user is already confirmed' do
    user = create_user
    user.confirm
    refute user.resend_confirmation_instructions
    assert user.confirmed?
    assert_equal 'was already confirmed, please try signing in', user.errors[:email].join
  end

  test 'confirm time should fallback to devise confirm in default configuration' do
    swap Devise, allow_unconfirmed_access_for: 1.day do
      user = create_user
      user.confirmation_sent_at = 2.days.ago
      refute user.active_for_authentication?

      Devise.allow_unconfirmed_access_for = 3.days
      assert user.active_for_authentication?
    end
  end

  test 'should be active when confirmation sent at is not overpast' do
    swap Devise, allow_unconfirmed_access_for: 5.days do
      Devise.allow_unconfirmed_access_for = 5.days
      user = create_user

      user.confirmation_sent_at = 4.days.ago
      assert user.active_for_authentication?

      user.confirmation_sent_at = 5.days.ago
      refute user.active_for_authentication?
    end
  end

  test 'should be active when already confirmed' do
    user = create_user
    refute user.confirmed?
    refute user.active_for_authentication?

    user.confirm
    assert user.confirmed?
    assert user.active_for_authentication?
  end

  test 'should not be active when confirm in is zero' do
    Devise.allow_unconfirmed_access_for = 0.days
    user = create_user
    user.confirmation_sent_at = Time.zone.today
    refute user.active_for_authentication?
  end

  test 'should be active when we set allow_unconfirmed_access_for to nil' do
    swap Devise, allow_unconfirmed_access_for: nil do
      user = create_user
      user.confirmation_sent_at = Time.zone.today
      assert user.active_for_authentication?
    end
  end

  test 'should not be active without confirmation' do
    user = create_user
    user.confirmation_sent_at = nil
    user.save
    refute user.reload.active_for_authentication?
  end

  test 'should be active without confirmation when confirmation is not required' do
    user = create_user
    user.instance_eval { def confirmation_required?; false end }
    user.confirmation_sent_at = nil
    user.save
    assert user.reload.active_for_authentication?
  end

  test 'should not break when a user tries to reset their password in the case where confirmation is not required and confirm_within is set' do
    swap Devise, confirm_within: 3.days do
      user = create_user
      user.instance_eval { def confirmation_required?; false end }
      user.confirmation_sent_at = nil
      user.save
      assert user.reload.confirm
    end
  end

  test 'should find a user to send email instructions for the user confirm its email by authentication_keys' do
    swap Devise, authentication_keys: [:username, :email] do
      user = create_user
      confirm_user = User.send_confirmation_instructions(email: user.email, username: user.username)
      assert_equal confirm_user, user
    end
  end

  test 'should require all confirmation_keys' do
    swap Devise, confirmation_keys: [:username, :email] do
      user = create_user
      confirm_user = User.send_confirmation_instructions(email: user.email)
      refute confirm_user.persisted?
      assert_equal "can't be blank", confirm_user.errors[:username].join
    end
  end

  def confirm_user_by_token_with_confirmation_sent_at(confirmation_sent_at)
    user = create_user
    user.update_attribute(:confirmation_sent_at, confirmation_sent_at)
    confirmed_user = User.confirm_by_token(user.raw_confirmation_token)
    assert_equal confirmed_user, user
    user.reload.confirmed?
  end

  test 'should accept confirmation email token even after 5 years when no expiration is set' do
    assert confirm_user_by_token_with_confirmation_sent_at(5.years.ago)
  end

  test 'should accept confirmation email token after 2 days when expiration is set to 3 days' do
    swap Devise, confirm_within: 3.days do
      assert confirm_user_by_token_with_confirmation_sent_at(2.days.ago)
    end
  end

  test 'should not accept confirmation email token after 4 days when expiration is set to 3 days' do
    swap Devise, confirm_within: 3.days do
      refute confirm_user_by_token_with_confirmation_sent_at(4.days.ago)
    end
  end

  test 'do not generate a new token on resend' do
    user = create_user
    old  = user.confirmation_token
    user = User.find(user.id)
    user.resend_confirmation_instructions
    assert_equal user.confirmation_token, old
  end

  test 'generate a new token after first has expired' do
    swap Devise, confirm_within: 3.days do
      user = create_user
      old = user.confirmation_token
      user.update_attribute(:confirmation_sent_at, 4.days.ago)
      user = User.find(user.id)
      user.resend_confirmation_instructions
      assert_not_equal user.confirmation_token, old
    end
  end

  test 'should call after_confirmation if confirmed' do
    user = create_user
    user.define_singleton_method :after_confirmation do
      self.username = self.username.to_s + 'updated'
    end
    old = user.username
    assert user.confirm
    assert_not_equal user.username, old
  end

  test 'should not call after_confirmation if not confirmed' do
    user = create_user
    assert user.confirm
    user.define_singleton_method :after_confirmation do
      self.username = self.username.to_s + 'updated'
    end
    old = user.username
    refute user.confirm
    assert_equal user.username, old
  end

  test 'should always perform validations upon confirm when ensure valid true' do
    admin = create_admin
    admin.stubs(:valid?).returns(false)
    refute admin.confirm(ensure_valid: true)
  end
end

class ReconfirmableTest < ActiveSupport::TestCase
  test 'should not worry about validations on confirm even with reconfirmable' do
    admin = create_admin
    admin.reset_password_token = "a"
    assert admin.confirm
  end

  test 'should generate confirmation token after changing email' do
    admin = create_admin
    assert admin.confirm
    residual_token = admin.confirmation_token
    assert admin.update_attributes(email: 'new_test@example.com')
    assert_not_equal residual_token, admin.confirmation_token
  end

  test 'should not regenerate confirmation token or require reconfirmation if skipping reconfirmation after changing email' do
    admin = create_admin
    original_token = admin.confirmation_token
    assert admin.confirm
    admin.skip_reconfirmation!
    assert admin.update_attributes(email: 'new_test@example.com')
    assert admin.confirmed?
    refute admin.pending_reconfirmation?
    assert_equal original_token, admin.confirmation_token
  end

  test 'should skip sending reconfirmation email when email is changed and skip_confirmation_notification! is invoked' do
    admin = create_admin
    admin.skip_confirmation_notification!

    assert_email_not_sent do
      admin.update_attributes(email: 'new_test@example.com')
    end
  end

  test 'should regenerate confirmation token after changing email' do
    admin = create_admin
    assert admin.confirm
    assert admin.update_attributes(email: 'old_test@example.com')
    token = admin.confirmation_token
    assert admin.update_attributes(email: 'new_test@example.com')
    assert_not_equal token, admin.confirmation_token
  end

  test 'should send confirmation instructions by email after changing email' do
    admin = create_admin
    assert admin.confirm
    assert_email_sent "new_test@example.com" do
      assert admin.update_attributes(email: 'new_test@example.com')
    end
    assert_match "new_test@example.com", ActionMailer::Base.deliveries.last.body.encoded
  end

  test 'should send confirmation instructions by email after changing email from nil' do
    admin = create_admin(email: nil)
    assert_email_sent "new_test@example.com" do
      assert admin.update_attributes(email: 'new_test@example.com')
    end
    assert_match "new_test@example.com", ActionMailer::Base.deliveries.last.body.encoded
  end

  test 'should not send confirmation by email after changing password' do
    admin = create_admin
    assert admin.confirm
    assert_email_not_sent do
      assert admin.update_attributes(password: 'newpass', password_confirmation: 'newpass')
    end
  end

  test 'should not send confirmation by email after changing to a blank email' do
    admin = create_admin
    assert admin.confirm
    assert_email_not_sent do
      admin.email = ''
      admin.save(validate: false)
    end
  end

  test 'should stay confirmed when email is changed' do
    admin = create_admin
    assert admin.confirm
    assert admin.update_attributes(email: 'new_test@example.com')
    assert admin.confirmed?
  end

  test 'should update email only when it is confirmed' do
    admin = create_admin
    assert admin.confirm
    assert admin.update_attributes(email: 'new_test@example.com')
    assert_not_equal 'new_test@example.com', admin.email
    assert admin.confirm
    assert_equal 'new_test@example.com', admin.email
  end

  test 'should not allow admin to get past confirmation email by resubmitting their new address' do
    admin = create_admin
    assert admin.confirm
    assert admin.update_attributes(email: 'new_test@example.com')
    assert_not_equal 'new_test@example.com', admin.email
    assert admin.update_attributes(email: 'new_test@example.com')
    assert_not_equal 'new_test@example.com', admin.email
  end

  test 'should find a admin by send confirmation instructions with unconfirmed_email' do
    admin = create_admin
    assert admin.confirm
    assert admin.update_attributes(email: 'new_test@example.com')
    confirmation_admin = Admin.send_confirmation_instructions(email: admin.unconfirmed_email)
    assert_equal confirmation_admin, admin
  end

  test 'should return a new admin if no email or unconfirmed_email was found' do
    confirmation_admin = Admin.send_confirmation_instructions(email: "invalid@email.com")
    refute confirmation_admin.persisted?
  end

  test 'should add error to new admin email if no email or unconfirmed_email was found' do
    confirmation_admin = Admin.send_confirmation_instructions(email: "invalid@email.com")
    assert confirmation_admin.errors[:email]
    assert_equal "not found", confirmation_admin.errors[:email].join
  end

  test 'should find admin with email in unconfirmed_emails' do
    admin = create_admin
    admin.unconfirmed_email = "new_test@email.com"
    assert admin.save
    admin = Admin.find_by_unconfirmed_email_with_errors(email: "new_test@email.com")
    assert admin.persisted?
  end

  test 'required_fields should contain the fields that Devise uses' do
    assert_equal Devise::Models::Confirmable.required_fields(User), [
      :confirmation_token,
      :confirmed_at,
      :confirmation_sent_at
    ]
  end

  test 'required_fields should also contain unconfirmable when reconfirmable_email is true' do
    assert_equal Devise::Models::Confirmable.required_fields(Admin), [
      :confirmation_token,
      :confirmed_at,
      :confirmation_sent_at,
      :unconfirmed_email
    ]
  end

  test 'should not require reconfirmation after creating a record' do
    admin = create_admin
    assert !admin.pending_reconfirmation?
  end

  test 'should not require reconfirmation after creating a record with #save called in callback' do
    class Admin::WithSaveInCallback < Admin
      after_create :save
    end

    admin = Admin::WithSaveInCallback.create(valid_attributes.except(:username))
    assert !admin.pending_reconfirmation?
  end

  test 'should require reconfirmation after creating a record and updating the email' do
    admin = create_admin
    assert !admin.instance_variable_get(:@bypass_confirmation_postpone)
    admin.email = "new_test@email.com"
    admin.save
    assert admin.pending_reconfirmation?
  end

  test 'should notify previous email on email change when configured' do
    swap Devise, send_email_changed_notification: true do
      admin = create_admin
      original_email = admin.email

      assert_difference 'ActionMailer::Base.deliveries.size', 2 do
        assert admin.update_attributes(email: 'new-email@example.com')
      end
      assert_equal original_email, ActionMailer::Base.deliveries[-2]['to'].to_s
      assert_equal 'new-email@example.com', ActionMailer::Base.deliveries[-1]['to'].to_s

      assert_email_not_sent do
        assert admin.confirm
      end
    end
  end
end
