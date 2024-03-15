# frozen_string_literal: true

Fabricator(:notification_request) do
  account
  from_account { Fabricate.build(:account) }
  last_status { Fabricate.build(:status) }
  dismissed false
end
