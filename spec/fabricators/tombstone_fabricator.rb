# frozen_string_literal: true

Fabricator(:tombstone) do
  account
  uri { sequence(:uri) { |i| "https://host.example/value/#{i}" } }
end
