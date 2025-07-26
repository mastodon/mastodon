# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FollowRecommendationMute do
  it_behaves_like 'Recommendation Maintenance'

  describe 'Associations' do
    it { is_expected.to belong_to(:account) }
    it { is_expected.to belong_to(:target_account).class_name('Account') }
  end

  describe 'Validations' do
    subject { Fabricate.build :follow_recommendation_mute }

    it { is_expected.to validate_uniqueness_of(:target_account_id).scoped_to(:account_id) }
  end
end
