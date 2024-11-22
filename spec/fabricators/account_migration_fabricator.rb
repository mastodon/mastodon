# frozen_string_literal: true

Fabricator(:account_migration) do
  account
  target_account { |attrs| Fabricate(:account, also_known_as: [ActivityPub::TagManager.instance.uri_for(attrs[:account])]) }
  acct           { |attrs| attrs[:target_account].acct }
  followers_count 1234
  created_at { 60.days.ago }
end
