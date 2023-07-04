# frozen_string_literal: true

Fabricator(:follow) do
  account { Fabricate.build(:account) }
  target_account { Fabricate.build(:account) }
end
