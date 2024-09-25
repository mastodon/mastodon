# frozen_string_literal: true

Fabricator(:notification_permission) do
  account
  from_account { Fabricate.build(:account) }
end
