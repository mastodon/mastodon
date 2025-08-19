# frozen_string_literal: true

Fabricator(:bulk_import) do
  type :blocking
  state :scheduled
  account { Fabricate.build(:account) }
end
