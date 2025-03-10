# frozen_string_literal: true

Fabricator(:unavailable_domain) do
  domain { sequence(:domain) { |i| "host-#{i}-name.example" } }
end
