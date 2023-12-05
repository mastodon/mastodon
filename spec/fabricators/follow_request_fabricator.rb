# frozen_string_literal: true

Fabricator(:follow_request) do
  account { Fabricate.build(:account) }
  target_account { Fabricate.build(:account, locked: true) }
end
