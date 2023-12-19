# frozen_string_literal: true

Fabricator(:account_note) do
  account { Fabricate.build(:account) }
  target_account { Fabricate.build(:account) }
  comment        'User note text'
end
