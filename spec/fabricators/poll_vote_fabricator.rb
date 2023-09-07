# frozen_string_literal: true

Fabricator(:poll_vote) do
  account { Fabricate.build(:account) }
  poll
  choice 0
end
