# frozen_string_literal: true

Fabricator(:collection) do
  account      { Fabricate.build(:account) }
  name         { sequence(:name) { |i| "Collection ##{i}" } }
  description  'People to follow'
  local        true
  sensitive    false
  discoverable true
end
