# frozen_string_literal: true

require 'test_helper'

class ResetPasswordInstructionsTest < ActionMailer::TestCase
  def setup
    setup_mailer
    Devise.mailer = 'Devise::Mailer'
    Devise.mailer_sender = 'test@example.com'
  end

  def teardown
    Devise.mailer = 'Devise::Mailer'
    Devise.mailer_sender = 'please-change-me@config-initializers-devise.com'
  end

  def user
    @user ||= begin
      user = create_user
      user.send_reset_password_instructions
      user
    end
  end

  def mail
    @mail ||= begin
      user
      ActionMailer::Base.deliveries.last
    end
  end

  test 'email sent after reseting the user password' do
    assert_not_nil mail
  end

  test 'content type should be set to html' do
    assert mail.content_type.include?('text/html')
  end

  test 'send confirmation instructions to the user email' do
    assert_equal [user.email], mail.to
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

  test 'set up subject from I18n' do
    store_translations :en, devise: { mailer: { reset_password_instructions: { subject: 'Reset instructions' } } } do
      assert_equal 'Reset instructions', mail.subject
    end
  end

  test 'subject namespaced by model' do
    store_translations :en, devise: { mailer: { reset_password_instructions: { user_subject: 'User Reset Instructions' } } } do
      assert_equal 'User Reset Instructions', mail.subject
    end
  end

  test 'body should have user info' do
    assert_match user.email, mail.body.encoded
  end

  test 'body should have link to confirm the account' do
    host, port = ActionMailer::Base.default_url_options.values_at :host, :port

    if mail.body.encoded =~ %r{<a href=\"http://#{host}:#{port}/users/password/edit\?reset_password_token=([^"]+)">}
      assert_equal Devise.token_generator.digest(user.class, :reset_password_token, $1), user.reset_password_token
    else
      flunk "expected reset password url regex to match"
    end
  end

  test 'mailer sender accepts a proc' do
    swap Devise, mailer_sender: proc { "another@example.com" } do
      assert_equal ['another@example.com'], mail.from
    end
  end
end
