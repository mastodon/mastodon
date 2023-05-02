# frozen_string_literal: true

Fabricator(:account_reach_filter) do
  account
  bloom_filter { "\x00".encode('ASCII-8BIT') * 5991 }
  salt         { SecureRandom.alphanumeric(4) }
end
