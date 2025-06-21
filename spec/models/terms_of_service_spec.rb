# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TermsOfService do
  describe '#scope_for_notification' do
    subject { terms_of_service.scope_for_notification }

    let(:published_at) { Time.now.utc }
    let(:terms_of_service) { Fabricate(:terms_of_service, published_at: published_at) }
    let(:user_before) { Fabricate(:user, created_at: published_at - 2.days) }
    let(:user_before_unconfirmed) { Fabricate(:user, created_at: published_at - 2.days, confirmed_at: nil) }
    let(:user_before_suspended) { Fabricate(:user, created_at: published_at - 2.days) }
    let(:user_after) { Fabricate(:user, created_at: published_at + 1.hour) }

    before do
      user_before_suspended.account.suspend!
      user_before_unconfirmed
      user_before
      user_after
    end

    it 'includes only users created before the terms of service were published' do
      expect(subject.pluck(:id)).to match_array(user_before.id)
    end
  end

  describe '::current' do
    context 'when no terms exist' do
      it 'returns nil' do
        expect(described_class.current).to be_nil
      end
    end

    context 'when only unpublished terms exist' do
      before do
        yesterday = Date.yesterday
        travel_to yesterday do
          Fabricate(:terms_of_service, published_at: nil, effective_date: yesterday)
        end
        Fabricate(:terms_of_service, published_at: nil, effective_date: Date.tomorrow)
      end

      it 'returns nil' do
        expect(described_class.current).to be_nil
      end
    end

    context 'when both effective and future terms exist' do
      let!(:effective_terms) do
        yesterday = Date.yesterday
        travel_to yesterday do
          Fabricate(:terms_of_service, effective_date: yesterday)
        end
      end

      before do
        Fabricate(:terms_of_service, effective_date: Date.tomorrow)
      end

      it 'returns the effective terms' do
        expect(described_class.current).to eq effective_terms
      end
    end

    context 'when only future terms exist' do
      let!(:upcoming_terms) { Fabricate(:terms_of_service, effective_date: Date.tomorrow) }

      before do
        Fabricate(:terms_of_service, effective_date: 10.days.since)
      end

      it 'returns the terms that are upcoming next' do
        expect(described_class.current).to eq upcoming_terms
      end
    end
  end
end
