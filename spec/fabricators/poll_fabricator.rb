Fabricator(:poll) do
  account
  status
  expires_at  { 7.days.from_now }
  options     %w(Foo Bar)
  multiple    false
  hide_totals false
end
