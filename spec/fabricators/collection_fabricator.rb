# frozen_string_literal: true

Fabricator(:collection) do
  account      { Fabricate.build(:account) }
  name         { sequence(:name) { |i| "Collection ##{i}" } }
  description  'People to follow'
  local        true
  sensitive    false
  discoverable true
end

Fabricator(:remote_collection, from: :collection) do
  account { Fabricate.build(:remote_account) }
  local false
  uri { sequence(:uri) { |i| "https://example.com/collections/#{i}" } }
  original_number_of_items 0
end
