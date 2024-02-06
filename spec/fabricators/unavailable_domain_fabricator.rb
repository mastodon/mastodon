# frozen_string_literal: true

Fabricator(:unavailable_domain) do
  domain { Faker::Internet.domain_name }
end
