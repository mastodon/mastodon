# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Form::FollowRecommendationBatch do
  describe '#persisted?' do
    it { is_expected.to be_persisted }
  end

  describe '#save' do
    subject { described_class.new(action:, account_ids:, current_account: admin).save }

    let(:account_ids) { [account.id] }
    let(:account) { Fabricate :account }
    let(:admin) { Fabricate :account, user: Fabricate(:admin_user) }

    context 'when action is suppress_follow_recommendation' do
      let(:action) { 'suppress_follow_recommendation' }

      it 'adds a suppression for the accounts' do
        expect { subject }
          .to change(FollowRecommendationSuppression, :count).by(1)
          .and change { account.reload.follow_recommendation_suppression }.from(be_nil).to(be_present)
      end
    end

    context 'when action is unsuppress_follow_recommendation' do
      let(:action) { 'unsuppress_follow_recommendation' }

      before { Fabricate :follow_recommendation_suppression, account: }

      it 'removes a suppression for the accounts' do
        expect { subject }
          .to change(FollowRecommendationSuppression, :count).by(-1)
          .and change { account.reload.follow_recommendation_suppression }.from(be_present).to(be_nil)
      end
    end

    context 'when action is unknown' do
      let(:action) { 'unknown' }

      it { is_expected.to be_nil }
    end
  end
end
