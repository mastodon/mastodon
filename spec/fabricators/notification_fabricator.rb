# frozen_string_literal: true

Fabricator(:notification) do
  activity fabricator: :status
  account { Fabricate.build(:account) }
end
