# frozen_string_literal: true

Fabricator(:moderation_subscription) do
  type                :csv_list
  url                 { Faker::Internet.url }
  list_action         :reject
  apply_automatically false
end
