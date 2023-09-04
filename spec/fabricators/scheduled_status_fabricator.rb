Fabricator(:scheduled_status) do
  account
  scheduled_at { 20.hours.from_now }
end
