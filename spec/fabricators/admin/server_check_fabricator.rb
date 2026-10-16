# frozen_string_literal: true

Fabricator('Admin::ServerCheck') do
  key { Faker::Lorem.word }
  status(:unprocessed)
  severity(:critical)
  ignored(false)
  data { {} }
  checked_at(DateTime.now)
end
