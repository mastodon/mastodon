Fabricator(:stripe_subscription, from: Subscription::StripeSubscription) do
  invite { Fabricate(:invite) }
  subscription_id { sequence(:subscription_id) { |i| "sub_#{i}" } }
  customer_id { sequence(:customer_id) { |i| "cus_#{i}" } }
  status { "active" }
  user_id { nil }
end