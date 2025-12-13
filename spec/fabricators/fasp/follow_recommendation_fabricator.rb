# frozen_string_literal: true

Fabricator(:fasp_follow_recommendation, from: 'Fasp::FollowRecommendation') do
  requesting_account { Fabricate.build(:account) }
  recommended_account { Fabricate.build(:account, domain: 'fedi.example.com') }
end
