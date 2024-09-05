# frozen_string_literal: true

Fabricator(:ip_block) do
  severity { :sign_up_requires_approval }
  ip { sequence(:ip) { |n| "10.0.0.#{n}" } }
end
