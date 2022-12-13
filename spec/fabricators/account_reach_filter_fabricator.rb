# frozen_string_literal: true

Fabricator(:account_reach_filter) do
  account
  salt { SecureRandom.alphanumeric(4) }
end
