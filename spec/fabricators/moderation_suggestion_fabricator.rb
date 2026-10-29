# frozen_string_literal: true

Fabricator(:moderation_suggestion) do
  moderation_subscription
  action                  :reject
  target_type             :domain
  target_key              { Faker::Internet.domain_name }
end
