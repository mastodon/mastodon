# frozen_string_literal: true

Fabricator('Fasp::Subscription') do
  category            'MyString'
  subscription_type   'MyString'
  max_batch_size      1
  threshold_timeframe 1
  threshold_shares    1
  threshold_likes     1
  threshold_replies   1
  fasp_provider       nil
end
