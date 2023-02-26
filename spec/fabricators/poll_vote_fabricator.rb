# frozen_string_literal: true

Fabricator(:poll_vote) do
  account
  poll
  choice 0
end
