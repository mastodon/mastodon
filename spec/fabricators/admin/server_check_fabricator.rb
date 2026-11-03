# frozen_string_literal: true

Fabricator('Admin::ServerCheck') do
  key { sequence { |n| "key-#{n}" } }
  status(:unprocessed)
  severity(:critical)
  ignored(false)
  data { {} }
  checked_at(DateTime.now)
end
