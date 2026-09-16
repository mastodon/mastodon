# frozen_string_literal: true

Fabricator(:account_reach_filter) do
  account do
    # Awful hack but ensures we have the right reach filter regardless of configuration
    Fabricate(:account).tap { |account| account.reach_filter&.destroy }
  end

  salt { SecureRandom.alphanumeric(4) }
end
