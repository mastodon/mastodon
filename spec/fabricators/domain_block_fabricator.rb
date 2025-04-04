# frozen_string_literal: true

Fabricator(:domain_block) do
  domain { sequence(:domain) { |i| "host-#{i}-name.example" } }
end
