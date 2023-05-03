# frozen_string_literal: true

Fabricator(:preview_card_provider) do
  domain { Faker::Internet.domain_name }
end
