Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # The test environment is used exclusively to run your application's
  # test suite. You never need to work with it otherwise. Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs. Don't rely on the data there!
  config.cache_classes = true

  # Do not eager load code on boot. This avoids loading your whole application
  # just for the purpose of running a single test. If you are using a tool that
  # preloads Rails for running tests, you may have to set it to true.
  config.eager_load = false

  config.assets.digest = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # The default store, file_store is shared by processes parallelly executed
  # and should not be used.
  config.cache_store = :memory_store

  # Raise exceptions instead of rendering exception templates.
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false
  config.action_mailer.perform_caching = false

  config.action_mailer.default_options = { from: 'notifications@localhost' }

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  # Print deprecation notices to the stderr.
  config.active_support.deprecation = :stderr

  config.x.otp_secret = '100c7faeef00caa29242f6b04156742bf76065771fd4117990c4282b8748ff3d99f8fdae97c982ab5bd2e6756a159121377cce4421f4a8ecd2d67bd7749a3fb4'

  # Generate random VAPID keys
  vapid_key = Webpush.generate_key
  config.x.vapid_private_key = vapid_key.private_key
  config.x.vapid_public_key = vapid_key.public_key

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  config.i18n.default_locale = :en
  config.i18n.fallbacks = true

  config.to_prepare do
    # Force Status to always be SHAPE_TOO_COMPLEX
    # Ref: https://github.com/mastodon/mastodon/issues/23644
    10.times { |i| Status.allocate.instance_variable_set(:"@ivar_#{i}", nil) }
  end
end

Paperclip::Attachment.default_options[:path] = "#{Rails.root}/spec/test_files/:class/:id_partition/:style.:extension"

# set fake_data for pam, don't do real calls, just use fake data
if ENV['PAM_ENABLED'] == 'true'
  Rpam2.fake_data =
    {
      usernames: Set['pam_user1', 'pam_user2'],
      servicenames: Set['pam_test', 'pam_test_controlled'],
      password: '123456',
      env: { email: 'pam@example.com' }
    }
end

# Catch serialization warnings early
Sidekiq.strict_args!

Redis.raise_deprecations = true
