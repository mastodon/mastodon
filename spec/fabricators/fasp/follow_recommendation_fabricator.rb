# frozen_string_literal: true

Fabricator('Fasp::FollowRecommendation') do
  requesting_account { Fabricate.build(:account) }
  recommended_account { Fabricate.build(:account, domain: 'fedi.example.com') }
end
