# frozen_string_literal: true

Fabricator(:favourite) do
  account { Fabricate.build(:account) }
  status { Fabricate.build(:status) }
end
