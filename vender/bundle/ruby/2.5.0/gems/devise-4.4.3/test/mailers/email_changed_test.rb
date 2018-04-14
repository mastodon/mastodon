# frozen_string_literal: true

require 'test_helper'

class EmailChangedTest < ActionMailer::TestCase
  def setup
    setup_mailer
    Devise.mailer = 'Devise::Mailer'
    Devise.mailer_sender = 'test@example.com'
    Devise.send_email_changed_notification = true
  end

  def teardown
    Devise.mailer = 'Devise::Mailer'
    Devise.mailer_sender = 'please-change-me@config-initializers-devise.com'
    Devise.send_email_changed_notification = false
  end

  def user
    @user ||= create_user.tap { |u|
      @original_user_email = u.email
      u.update_attributes!(email: 'new-email@example.com')
    }
  end

  def mail
    @mail ||= begin
      user
      ActionMailer::Base.deliveries.last
    end
  end

  test 'email sent after changing the user email' do
    assert_not_nil mail
  end

  test 'content type should be set to html' do
    assert mail.content_type.include?('text/html')
  end

  test 'send email changed to the original user email' do
    mail
    assert_equal [@original_user_email], mail.to
  end

  test 'set up sender from configuration' do
    assert_equal ['test@example.com'], mail.from
  end

  test 'set up sender from custom mailer defaults' do
    Devise.mailer = 'Users::Mailer'
    assert_equal ['custom@example.com'], mail.from
  end

  test 'set up sender from custom mailer defaults with proc' do
    Devise.mailer = 'Users::FromProcMailer'
    assert_equal ['custom@example.com'], mail.from
  end

  test 'custom mailer renders parent mailer template' do
    Devise.mailer = 'Users::Mailer'
    assert_present mail.body.encoded
  end

  test 'set up reply to as copy from sender' do
    assert_equal ['test@example.com'], mail.reply_to
  end

  test 'set up reply to as different if set in defaults' do
    Devise.mailer = 'Users::ReplyToMailer'
    assert_equal ['custom@example.com'], mail.from
    assert_equal ['custom_reply_to@example.com'], mail.reply_to
  end

  test 'set up subject from I18n' do
    store_translations :en, devise: { mailer: { email_changed: { subject: 'Email Has Changed' } } } do
      assert_equal 'Email Has Changed', mail.subject
    end
  end

  test 'subject namespaced by model' do
    store_translations :en, devise: { mailer: { email_changed: { user_subject: 'User Email Has Changed' } } } do
      assert_equal 'User Email Has Changed', mail.subject
    end
  end

  test 'body should have user info' do
    body = mail.body.encoded
    assert_match "Hello #{@original_user_email}", body
    assert_match "has been changed to #{user.email}", body
  end
end

class EmailChangedReconfirmationTest < ActionMailer::TestCase
  def setup
    setup_mailer
    Devise.mailer = 'Devise::Mailer'
    Devise.mailer_sender = 'test@example.com'
    Devise.send_email_changed_notification = true
  end

  def teardown
    Devise.mailer = 'Devise::Mailer'
    Devise.mailer_sender = 'please-change-me@config-initializers-devise.com'
    Devise.send_email_changed_notification = false
  end

  def admin
    @admin ||= create_admin.tap { |u|
      @original_admin_email = u.email
      u.update_attributes!(email: 'new-email@example.com')
    }
  end

  def mail
    @mail ||= begin
      admin
      ActionMailer::Base.deliveries[-2]
    end
  end

  test 'send email changed to the original user email' do
    mail
    assert_equal [@original_admin_email], mail.to
  end

  test 'body should have unconfirmed user info' do
    body = mail.body.encoded
    assert_match admin.email, body
    assert_match "is being changed to #{admin.unconfirmed_email}", body
  end
end
