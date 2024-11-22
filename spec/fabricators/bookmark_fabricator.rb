# frozen_string_literal: true

Fabricator(:bookmark) do
  account { Fabricate.build(:account) }
  status { Fabricate.build(:status) }
end
