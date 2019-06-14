Fabricator(:featured_tag) do
  account
  tag
  statuses_count 1_337
  last_status_at Time.now.utc
end
