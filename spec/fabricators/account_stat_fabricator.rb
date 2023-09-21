# frozen_string_literal: true

Fabricator(:account_stat) do
  account { Fabricate.build(:account) }
  statuses_count  '123'
  following_count '456'
  followers_count '789'
end
