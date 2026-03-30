# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FollowLimitValidator do
  subject { Fabricate.build(:follow) }

  context 'with a nil account' do
    it { is_expected.to allow_values(nil).for(:account).against(:base) }
  end

  context 'with a non-local account' do
    let(:account) { Account.new(domain: 'host.example') }

    it { is_expected.to allow_values(account).for(:account).against(:base) }
  end

  context 'with a local account' do
    let(:account) { Account.new }

    context 'when the followers count is under the limit' do
      before { account.following_count = described_class::LIMIT - 100 }

      it { is_expected.to allow_values(account).for(:account).against(:base) }
    end

    context 'when the following count is over the limit' do
      before { account.following_count = described_class::LIMIT + 100 }

      context 'when the followers count is low' do
        before { account.followers_count = 10 }

        it { is_expected.to_not allow_values(account).for(:account).against(:base).with_message(limit_reached_message) }

        def limit_reached_message
          I18n.t('users.follow_limit_reached', limit: described_class::LIMIT)
        end
      end

      context 'when the followers count is high' do
        before { account.followers_count = 100_000 }

        it { is_expected.to allow_values(account).for(:account).against(:base) }
      end
    end
  end
end
