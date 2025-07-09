# frozen_string_literal: true

Fabricator(:fasp_subscription, from: 'Fasp::Subscription') do
  category            'content'
  subscription_type   'lifecycle'
  max_batch_size      10
  fasp_provider
end
