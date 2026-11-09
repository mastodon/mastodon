# frozen_string_literal: true

Fabricator(:moderation_subscription) do
  name                { sequence(:username) { |i| "#{Faker::Internet.user_name(separators: %w(_))}#{i}" } }
  priority            { sequence(:priority) }
  type                :csv_list
  url                 { Faker::Internet.url }
  list_action         :reject
  apply_automatically false
end
