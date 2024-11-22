# frozen_string_literal: true

Fabricator(:report) do
  account { Fabricate.build(:account) }
  target_account  { Fabricate.build(:account) }
  comment         'You nasty'
  action_taken_at nil
end
