# frozen_string_literal: true

require 'test_helper'

class ConfirmationInstructionsTest < ActionMailer::TestCase

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
    @user ||= create_user
  end

  def mail
    @mail ||= begin
      user
      ActionMailer::Base.deliveries.first
    end
  end

  test 'email sent after creating the user' do
    assert_not_nil mail
  end

  test 'content type should be set to html' do
    assert mail.content_type.include?('text/html')
  end

  test 'send confirmation instructions to the user email' do
    mail
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

  test 'set up reply to as different if set in defaults' do
    Devise.mailer = 'Users::ReplyToMailer'
    assert_equal ['custom@example.com'], mail.from
    assert_equal ['custom_reply_to@example.com'], mail.reply_to
  end

  test 'set up subject from I18n' do
    store_translations :en, devise: { mailer: { confirmation_instructions: { subject: 'Account Confirmation' } } } do
      assert_equal 'Account Confirmation', mail.subject
    end
  end

  test 'subject namespaced by model' do
    store_translations :en, devise: { mailer: { confirmation_instructions: { user_subject: 'User Account Confirmation' } } } do
      assert_equal 'User Account Confirmation', mail.subject
    end
  end

  test 'body should have user info' do
    assert_match user.email, mail.body.encoded
  end

  test 'body should have link to confirm the account' do
    host, port = ActionMailer::Base.default_url_options.values_at :host, :port

    if mail.body.encoded =~ %r{<a href=\"http://#{host}:#{port}/users/confirmation\?confirmation_token=([^"]+)">}
      assert_equal $1, user.confirmation_token
    else
      flunk "expected confirmation url regex to match"
    end
  end

  test 'renders a scoped if scoped_views is set to true' do
    swap Devise, scoped_views: true do
      assert_equal user.email, mail.body.decoded
    end
  end

  test 'renders a scoped if scoped_views is set in the mailer class' do
    begin
      Devise::Mailer.scoped_views = true
      assert_equal user.email, mail.body.decoded
    ensure
      Devise::Mailer.send :remove_instance_variable, :@scoped_views
    end
  end

  test 'mailer sender accepts a proc' do
    swap Devise, mailer_sender: proc { "another@example.com" } do
      assert_equal ['another@example.com'], mail.from
    end
  end
end
