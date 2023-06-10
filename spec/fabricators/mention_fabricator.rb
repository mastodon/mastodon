# frozen_string_literal: true

Fabricator(:mention) do
  account { Fabricate.build(:account) }
  status { Fabricate.build(:status) }
end
