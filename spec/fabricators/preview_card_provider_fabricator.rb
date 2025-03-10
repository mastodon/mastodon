# frozen_string_literal: true

Fabricator(:preview_card_provider) do
  domain { sequence(:domain) { |i| "host-#{i}-name.example" } }
end
