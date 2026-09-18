# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin FollowRecommendations Suppressions' do
  before { sign_in Fabricate(:admin_user) }

  describe 'POST /admin/accounts/:account_id/follow_recommendations/suppression' do
    let(:account) { Fabricate(:account) }

    it 'suppress account from follow recommendations' do
      post admin_account_follow_recommendations_suppression_path(account.id)

      expect(response)
        .to redirect_to(admin_account_path(account.id))
      expect(account.reload.follow_recommendation_suppression)
        .to_not be_nil
    end
  end

  describe 'DELETE /admin/accounts/:account_id/follow_recommendations/suppression' do
    before { FollowRecommendationSuppression.create(account:) }

    let(:account) { Fabricate(:account) }

    it 'allows account in follow recommendations' do
      delete admin_account_follow_recommendations_suppression_path(account.id)

      expect(response)
        .to redirect_to(admin_account_path(account.id))
      expect(account.reload.follow_recommendation_suppression)
        .to be_nil
    end
  end
end
