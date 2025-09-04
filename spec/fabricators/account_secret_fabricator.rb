# frozen_string_literal: true

Fabricator(:account_secret) do
  account
  private_key { OpenSSL::PKey::RSA.new(2048).to_pem }
end
