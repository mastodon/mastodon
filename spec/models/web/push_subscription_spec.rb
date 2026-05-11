# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Web::PushSubscription do
  subject { described_class.new(data: data) }

  let(:account) { Fabricate(:account) }

  let(:policy) { 'all' }

  let(:data) do
    {
      policy: policy,

      alerts: {
        mention: true,
        reblog: false,
        follow: true,
        follow_request: false,
        favourite: true,
      },
    }
  end

  describe '#pushable?' do
    let(:notification_type) { :mention }
    let(:notification) { Fabricate(:notification, account: account, type: notification_type) }

    %i(mention reblog follow follow_request favourite).each do |type|
      context "when notification is a #{type}" do
        let(:notification_type) { type }

        it 'returns boolean corresponding to alert setting' do
          expect(subject.pushable?(notification)).to eq data[:alerts][type]
        end
      end
    end

    context 'when policy is all' do
      let(:policy) { 'all' }

      it 'returns true' do
        # Predicate matcher syntax automatically delegates to `pushable?`
        expect(subject).to be_pushable(notification)
      end
    end

    context 'when policy is none' do
      let(:policy) { 'none' }

      it 'returns false' do
        # Predicate matcher syntax automatically delegates to `pushable?`
        expect(subject).to_not be_pushable(notification)
      end
    end

    context 'when policy is followed' do
      let(:policy) { 'followed' }

      context 'when notification is from someone you follow' do
        before do
          account.follow!(notification.from_account)
        end

        it 'returns true' do
          expect(subject).to be_pushable(notification)
        end
      end

      context 'when notification is not from someone you follow' do
        it 'returns false' do
          expect(subject).to_not be_pushable(notification)
        end
      end
    end

    context 'when policy is follower' do
      let(:policy) { 'follower' }

      context 'when notification is from someone who follows you' do
        before do
          notification.from_account.follow!(account)
        end

        it 'returns true' do
          expect(subject).to be_pushable(notification)
        end
      end

      context 'when notification is not from someone who follows you' do
        it 'returns false' do
          expect(subject).to_not be_pushable(notification)
        end
      end
    end

    context 'when alerts configuration is missing' do
      let(:data) { nil }

      it 'returns false' do
        expect(subject).to_not be_pushable(notification)
      end
    end

    context 'when notification type is not configured in alerts' do
      let(:notification_type) { :poll }

      it 'returns false' do
        expect(subject).to_not be_pushable(notification)
      end
    end

    context 'when policy is missing' do
      let(:data) do
        {
          alerts: {
            mention: true,
          },
        }
      end

      it 'returns true' do
        expect(subject).to be_pushable(notification)
      end
    end

    context 'when policy is unknown' do
      let(:policy) { 'unknown' }

      it 'returns a falsey value' do
        # Predicate matcher syntax automatically delegates to `pushable?`
        expect(subject).to_not be_pushable(notification)
      end
    end
  end

  describe 'Delegations' do
    it { is_expected.to delegate_method(:token).to(:access_token).with_prefix(:associated_access) }
  end

  describe '.unsubscribe_for' do
    let(:application) { Fabricate(:application) }
    let(:user) { Fabricate(:user, account: account) }
    let(:subscription) do
      Fabricate(
        :web_push_subscription,
        user: user,
        access_token: access_token
      )
    end

    let(:access_token) do
      Fabricate(
        :accessible_access_token,
        application: application,
        resource_owner_id: user.id
      )
    end

    before do
      subscription
    end

    it 'removes subscriptions for matching application and resource owner' do
      expect do
        described_class.unsubscribe_for(application.id, user)
      end.to change(described_class, :count).by(-1)
    end
  end
end
