Rails.application.config.middleware.use OmniAuth::Builder do
  # Vanilla omniauth stategies
end

Devise.setup do |config|
  # Devise omniauth strategies
  options = {}
  options[:redirect_at_sign_in] = ENV['OAUTH_REDIRECT_AT_SIGN_IN'] == 'true'

  # CAS strategy
  if ENV['CAS_ENABLED'] == 'true'
    cas_options = options
    cas_options[:url] = ENV['CAS_URL'] if ENV['CAS_URL']
    cas_options[:host] = ENV['CAS_HOST'] if ENV['CAS_HOST']
    cas_options[:port] = ENV['CAS_PORT'] if ENV['CAS_PORT']
    cas_options[:ssl] = ENV['CAS_SSL'] == 'true' if ENV['CAS_SSL']
    cas_options[:service_validate_url] = ENV['CAS_VALIDATE_URL'] if ENV['CAS_VALIDATE_URL']
    cas_options[:callback_url] = ENV['CAS_CALLBACK_URL'] if ENV['CAS_CALLBACK_URL']
    cas_options[:logout_url] = ENV['CAS_LOGOUT_URL'] if ENV['CAS_LOGOUT_URL']
    cas_options[:login_url] = ENV['CAS_LOGIN_URL'] if ENV['CAS_LOGIN_URL']
    cas_options[:uid_field] = ENV['CAS_UID_FIELD'] || 'user' if ENV['CAS_UID_FIELD']
    cas_options[:ca_path] = ENV['CAS_CA_PATH'] if ENV['CAS_CA_PATH']
    cas_options[:disable_ssl_verification] = ENV['CAS_DISABLE_SSL_VERIFICATION'] == 'true'
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

  # SAML strategy
  if ENV['SAML_ENABLED'] == 'true'
    saml_options = options
    saml_options[:assertion_consumer_service_url] = ENV['SAML_ACS_URL'] if ENV['SAML_ACS_URL']
    saml_options[:issuer] = ENV['SAML_ISSUER'] if ENV['SAML_ISSUER']
    saml_options[:idp_sso_target_url] = ENV['SAML_IDP_SSO_TARGET_URL'] if ENV['SAML_IDP_SSO_TARGET_URL']
    saml_options[:idp_sso_target_url_runtime_params] = ENV['SAML_IDP_SSO_TARGET_PARAMS'] if ENV['SAML_IDP_SSO_TARGET_PARAMS'] # FIXME: Should be parsable Hash
    saml_options[:idp_cert] = ENV['SAML_IDP_CERT'] if ENV['SAML_IDP_CERT']
    saml_options[:idp_cert_fingerprint] = ENV['SAML_IDP_CERT_FINGERPRINT'] if ENV['SAML_IDP_CERT_FINGERPRINT']
    saml_options[:idp_cert_fingerprint_validator] = ENV['SAML_IDP_CERT_FINGERPRINT_VALIDATOR'] if ENV['SAML_IDP_CERT_FINGERPRINT_VALIDATOR'] # FIXME: Should be Lambda { |fingerprint| }
    saml_options[:name_identifier_format] = ENV['SAML_NAME_IDENTIFIER_FORMAT'] if ENV['SAML_NAME_IDENTIFIER_FORMAT']
    saml_options[:request_attributes] = {}
    saml_options[:certificate] = ENV['SAML_CERT'] if ENV['SAML_CERT']
    saml_options[:private_key] = ENV['SAML_PRIVATE_KEY'] if ENV['SAML_PRIVATE_KEY']
    saml_options[:security] = {}
    saml_options[:security][:want_assertions_signed] = ENV['SAML_SECURITY_WANT_ASSERTION_SIGNED'] == 'true'
    saml_options[:security][:want_assertions_encrypted] = ENV['SAML_SECURITY_WANT_ASSERTION_ENCRYPTED'] == 'true'
    saml_options[:security][:assume_email_is_verified] = ENV['SAML_SECURITY_ASSUME_EMAIL_IS_VERIFIED'] == 'true'
    saml_options[:attribute_statements] = {}
    saml_options[:attribute_statements][:uid] = [ENV['SAML_ATTRIBUTES_STATEMENTS_UID']] if ENV['SAML_ATTRIBUTES_STATEMENTS_UID']
    saml_options[:attribute_statements][:email] = [ENV['SAML_ATTRIBUTES_STATEMENTS_EMAIL']] if ENV['SAML_ATTRIBUTES_STATEMENTS_EMAIL']
    saml_options[:attribute_statements][:full_name] = [ENV['SAML_ATTRIBUTES_STATEMENTS_FULL_NAME']] if ENV['SAML_ATTRIBUTES_STATEMENTS_FULL_NAME']
    saml_options[:attribute_statements][:first_name] = [ENV['SAML_ATTRIBUTES_STATEMENTS_FIRST_NAME']] if ENV['SAML_ATTRIBUTES_STATEMENTS_FIRST_NAME']
    saml_options[:attribute_statements][:last_name] = [ENV['SAML_ATTRIBUTES_STATEMENTS_LAST_NAME']] if ENV['SAML_ATTRIBUTES_STATEMENTS_LAST_NAME']
    saml_options[:attribute_statements][:verified] = [ENV['SAML_ATTRIBUTES_STATEMENTS_VERIFIED']] if ENV['SAML_ATTRIBUTES_STATEMENTS_VERIFIED']
    saml_options[:attribute_statements][:verified_email] = [ENV['SAML_ATTRIBUTES_STATEMENTS_VERIFIED_EMAIL']] if ENV['SAML_ATTRIBUTES_STATEMENTS_VERIFIED_EMAIL']
    saml_options[:uid_attribute] = ENV['SAML_UID_ATTRIBUTE'] if ENV['SAML_UID_ATTRIBUTE']
    saml_options[:allowed_clock_drift] = ENV['SAML_ALLOWED_CLOCK_DRIFT'] if ENV['SAML_ALLOWED_CLOCK_DRIFT']
    config.omniauth :saml, saml_options
  end
end
