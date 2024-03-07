# frozen_string_literal: true

Fabricator(:notification_policy) do
  account
  filter_not_following false
  filter_not_followers false
  filter_new_accounts false
  filter_private_mentions true
end
