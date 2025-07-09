# frozen_string_literal: true

Fabricator(:quote) do
  status { Fabricate.build(:status) }
  quoted_status { Fabricate.build(:status) }
  state :pending
end
