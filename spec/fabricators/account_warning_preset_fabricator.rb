# frozen_string_literal: true

Fabricator(:account_warning_preset) do
  text { Faker::Lorem.paragraph }
  action_category { 'none' }
end
