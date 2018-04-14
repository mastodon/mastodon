# frozen_string_literal: true

require 'active_support/test_case'

class ActiveSupport::TestCase
  VALID_AUTHENTICATION_TOKEN = 'AbCdEfGhIjKlMnOpQrSt'.freeze

  def setup_mailer
    ActionMailer::Base.deliveries = []
  end

  def store_translations(locale, translations, &block)
    # Calling 'available_locales' before storing the translations to ensure
    # that the I18n backend will be initialized before we store our custom
    # translations, so they will always override the translations for the
    # YML file.
    I18n.available_locales
    I18n.backend.store_translations(locale, translations)
    yield
  ensure
    I18n.reload!
  end

  def generate_unique_email
    @@email_count ||= 0
    @@email_count += 1
    "test#{@@email_count}@example.com"
  end

  def valid_attributes(attributes={})
    { username: "usertest",
      email: generate_unique_email,
      password: '12345678',
      password_confirmation: '12345678' }.update(attributes)
  end

  def new_user(attributes={})
    User.new(valid_attributes(attributes))
  end

  def create_user(attributes={})
    User.create!(valid_attributes(attributes))
  end

  def create_admin(attributes={})
    valid_attributes = valid_attributes(attributes)
    valid_attributes.delete(:username)
    Admin.create!(valid_attributes)
  end

  def create_user_without_email(attributes={})
    UserWithoutEmail.create!(valid_attributes(attributes))
  end

  def create_user_with_validations(attributes={})
    UserWithValidations.create!(valid_attributes(attributes))
  end

  # Execute the block setting the given values and restoring old values after
  # the block is executed.
  def swap(object, new_values)
    old_values = {}
    new_values.each do |key, value|
      old_values[key] = object.send key
      object.send :"#{key}=", value
    end
    clear_cached_variables(new_values)
    yield
  ensure
    clear_cached_variables(new_values)
    old_values.each do |key, value|
      object.send :"#{key}=", value
    end
  end

  def clear_cached_variables(options)
    if options.key?(:case_insensitive_keys) || options.key?(:strip_whitespace_keys)
      Devise.mappings.each do |_, mapping|
        mapping.to.instance_variable_set(:@devise_parameter_filter, nil)
      end
    end
  end
end
