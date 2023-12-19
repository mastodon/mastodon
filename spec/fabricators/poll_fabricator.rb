# frozen_string_literal: true

Fabricator(:poll) do
  account { Fabricate.build(:account) }
  status { Fabricate.build(:status) }
  expires_at  { 7.days.from_now }
  options     %w(Foo Bar)
  multiple    false
  hide_totals false
end
