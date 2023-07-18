# frozen_string_literal: true

Fabricator(:domain_allow) do
  domain { sequence(:domain) { |i| "example#{i}.com" } }
end
