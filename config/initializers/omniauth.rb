Rails.application.config.middleware.use OmniAuth::Builder do
  # Vanilla omniauth stategies
end

Devise.setup do |config|
  # Devise omniauth strategies

  # Cas strategy
  if ENV['CAS_ENABLED'] == 'true'
    cas_options = {}
    cas_options[:url] = ENV['CAS_URL'] || "https://localhost:8443/"
    cas_options[:host] = ENV['CAS_HOST'] if ENV['CAS_HOST']
    cas_options[:port] = ENV['CAS_PORT'] if ENV['CAS_PORT']
    cas_options[:ssl] = ENV['CAS_SSL'] == 'true' if ENV['CAS_SSL']
    cas_options[:validate_url] = ENV['CAS_VALIDATE_URL'] if ENV['CAS_VALIDATE_URL']
    cas_options[:callback_url] = ENV['CAS_CALLBACK_URL'] if ENV['CAS_CALLBACK_URL']
    cas_options[:logout_url] = ENV['CAS_LOGOUT_URL'] if ENV['CAS_LOGOUT_URL']
    cas_options[:login_url] = ENV['CAS_LOGIN_URL'] if ENV['CAS_LOGIN_URL']
    cas_options[:uid_field] = ENV['CAS_UID_FIELD'] || 'user' if ENV['CAS_UID_FIELD']
    cas_options[:ca_path] = ENV['CAS_CA_PATH'] if ENV['CAS_CA_PATH']
    cas_options[:disable_ssl_verification] = ENV['CAS_DISABLE_SSL_VERIFICATION'] == 'true' if ENV['CAS_DISABLE_SSL_VERIFICATION']
    cas_options[:uid_key] = ENV['CAS_UID_KEY'] || 'user'
    cas_options[:name_key] = ENV['CAS_NAME_KEY'] || 'name'
    cas_options[:email_key] = ENV['CAS_EMAIL_KEY'] || 'email'
    cas_options[:nickname_key] = ENV['CAS_NICKNAME_KEY'] || 'nickname'
    cas_options[:first_name_key] = ENV['CAS_FIRST_NAME_KEY'] || 'firstname'
    cas_options[:last_name_key] = ENV['CAS_LAST_NAME_KEY'] || 'lastname'
    cas_options[:location_key] = ENV['CAS_LOCATION_KEY'] || 'location'
    cas_options[:image_key] = ENV['CAS_IMAGE_KEY'] || 'image'
    cas_options[:phone_key] = ENV['CAS_PHONE_KEY'] || 'phone'
    config.omniauth :cas, cas_options
  end

end
