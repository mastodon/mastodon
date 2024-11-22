# frozen_string_literal: true

Rails.application.configure do
  config.x.private_address_exceptions = (ENV['ALLOWED_PRIVATE_ADDRESSES'] || '').split(/(?:\s*,\s*|\s+)/).map { |addr| IPAddr.new(addr) }
end
