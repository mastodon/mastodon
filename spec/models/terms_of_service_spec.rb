# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TermsOfService do
  describe 'Validations' do
    subject { Fabricate.build :terms_of_service }

    it { is_expected.to validate_presence_of(:text) }
    it { is_expected.to validate_uniqueness_of(:effective_date) }

    it { is_expected.to allow_values(2.days.from_now).for(:effective_date) }
    it { is_expected.to_not allow_values(2.days.ago).for(:effective_date) }

    context 'with an existing published effective TOS' do
      before do
        travel_to 5.days.ago do
          Fabricate :terms_of_service, published_at: 2.days.ago, effective_date: 1.day.from_now
        end
      end

      it { is_expected.to allow_values(1.day.ago).for(:effective_date) }
    end

    context 'when published' do
      subject { Fabricate.build :terms_of_service, published_at: Time.zone.today }

      it { is_expected.to validate_presence_of(:changelog) }
      it { is_expected.to validate_presence_of(:effective_date) }
    end
  end

  describe 'Scopes' do
    describe '.published' do
      let!(:unpublished) { Fabricate :terms_of_service, published_at: nil }
      let!(:published_older_effective) { travel_to(3.days.ago) { Fabricate :terms_of_service, published_at: 5.days.ago, effective_date: Time.zone.today } }
      let!(:published_newer_effective) { travel_to(2.days.ago) { Fabricate :terms_of_service, published_at: 5.days.ago, effective_date: Time.zone.today } }

      it 'returns published records in correct order' do
        expect(described_class.published)
          .to eq([published_newer_effective, published_older_effective])
          .and not_include(unpublished)
      end
    end

    describe '.live' do
      # The `pre_effective_date` record captures a period before the value was tracked
      # The update in the `before` block creates an invalid (but historically plausible) record
      let!(:pre_effective_date) { travel_to(10.days.ago) { Fabricate :terms_of_service, effective_date: Time.zone.today } }
      let!(:effective_past) { travel_to(3.days.ago) { Fabricate :terms_of_service, effective_date: Time.zone.today } }
      let!(:effective_future) { Fabricate :terms_of_service, effective_date: 3.days.from_now }

      before { pre_effective_date.update_attribute(:effective_date, nil) }

      it 'returns records without effective or with past effective' do
        expect(described_class.live)
          .to include(pre_effective_date)
          .and include(effective_past)
          .and not_include(effective_future)
      end
    end

    describe '.upcoming' do
      let!(:unpublished) { Fabricate :terms_of_service, published_at: nil, effective_date: 10.days.from_now }
      let!(:effective_past) { travel_to(3.days.ago) { Fabricate :terms_of_service, effective_date: Time.zone.today } }
      let!(:effective_future_near) { Fabricate :terms_of_service, effective_date: 3.days.from_now }
      let!(:effective_future_far) { Fabricate :terms_of_service, effective_date: 5.days.from_now }

      it 'returns published records with future effective date in order of soonest first' do
        expect(described_class.upcoming)
          .to eq([effective_future_near, effective_future_far])
          .and not_include(unpublished)
          .and not_include(effective_past)
      end
    end

    describe '.draft' do
      let!(:published) { Fabricate :terms_of_service, published_at: 2.days.ago }
      let!(:unpublished) { Fabricate :terms_of_service, published_at: nil }

      it 'returns not published records' do
        expect(described_class.draft)
          .to include(unpublished)
          .and not_include(published)
      end
    end
  end

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
