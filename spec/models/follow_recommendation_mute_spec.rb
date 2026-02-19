# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FollowRecommendationMute do
  describe 'Associations' do
    it { is_expected.to belong_to(:account) }
    it { is_expected.to belong_to(:target_account).class_name('Account') }
  end

  describe 'Validations' do
    subject { Fabricate.build :follow_recommendation_mute }

    it { is_expected.to validate_uniqueness_of(:target_account_id).scoped_to(:account_id) }
  end

  describe 'Callbacks' do
    describe 'Maintaining the recommendation cache' do
      let(:account) { Fabricate :account }
      let(:cache_key) { "follow_recommendations/#{account.id}" }

      before { Rails.cache.write(cache_key, 123) }

      it 'purges on save' do
        expect { Fabricate :follow_recommendation_mute, account: account }
          .to(change { Rails.cache.exist?(cache_key) }.from(true).to(false))
      end
    end
  end
end
