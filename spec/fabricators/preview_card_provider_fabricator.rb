# frozen_string_literal: true

Fabricator(:preview_card_provider) do
  domain { sequence(:domain) { |i| "#{i}#{Faker::Internet.domain_name}" } }
end
