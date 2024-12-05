# frozen_string_literal: true

Fabricator(:unavailable_domain) do
  domain { sequence(:domain) { |i| "#{i}#{Faker::Internet.domain_name}" } }
end
