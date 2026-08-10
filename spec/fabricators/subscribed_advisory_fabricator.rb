# frozen_string_literal: true

Fabricator(:subscribed_advisory) do
  moderation_subscription
  action                  :reject
  target_type             :domain
  target_key              { Faker::Internet.domain_name }
end
