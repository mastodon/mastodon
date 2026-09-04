# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ModerationSubscriptionSyncService do
  subject { described_class.new }

  context 'with a CSV list' do
    let(:moderation_subscription) { Fabricate(:moderation_subscription, type: :csv_list) }

    context 'when the CSV list returns an error' do
      before do
        stub_request(:get, moderation_subscription.url)
          .to_return(status: 500)
      end

      it 'does not update the list' do
        expect { subject.call(moderation_subscription) }
          .to not_change(moderation_subscription, :updated_at)
          .and not_change(moderation_subscription, :advisories)
      end
    end

    context 'when the CSV list is only domains' do
      let(:raw_csv) do
        <<~CSV
          evil.com
          example.com
        CSV
      end

      before do
        moderation_subscription.advisories.create!(target_type: :domain, target_key: 'benign.com', action: :reject)

        stub_request(:get, moderation_subscription.url)
          .to_return(status: 200, headers: { 'Content-Type': 'text/csv' }, body: raw_csv)
      end

      it 'updates the list accordingly' do
        expect { subject.call(moderation_subscription) }
          .to change(moderation_subscription, :last_synced_at)

        expect(moderation_subscription.advisories.pluck(:target_type, :target_key, :action))
          .to contain_exactly(['domain', 'example.com', 'reject'], ['domain', 'evil.com', 'reject'])
      end
    end

    context 'when the CSV list has a header' do
      let(:raw_csv) do
        <<~CSV
          #domain,#severity
          evil.com,suspend
          example.com,suspend
        CSV
      end

      before do
        moderation_subscription.advisories.create!(target_type: :domain, target_key: 'benign.com', action: :reject)

        stub_request(:get, moderation_subscription.url)
          .to_return(status: 200, headers: { 'Content-Type': 'text/csv' }, body: raw_csv)
      end

      it 'updates the list accordingly' do
        expect { subject.call(moderation_subscription) }
          .to change(moderation_subscription, :last_synced_at)

        expect(moderation_subscription.advisories.pluck(:target_type, :target_key, :action))
          .to contain_exactly(['domain', 'example.com', 'reject'], ['domain', 'evil.com', 'reject'])
      end
    end
  end
end
