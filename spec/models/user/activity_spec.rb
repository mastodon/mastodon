# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User::Activity do
  before { stub_const 'User::ACTIVE_DURATION', 7.days }

  describe 'Scopes' do
    let!(:recent_sign_in_user) { Fabricate(:user, current_sign_in_at: 2.days.ago) }
    let!(:no_recent_sign_in_user) { Fabricate(:user, current_sign_in_at: 10.days.ago) }

    describe '.signed_in_recently' do
      it 'returns users who have signed in during the recent period' do
        expect(User.signed_in_recently)
          .to contain_exactly(recent_sign_in_user)
      end
    end

    describe '.not_signed_in_recently' do
      it 'returns users who have not signed in during the recent period' do
        expect(User.not_signed_in_recently)
          .to contain_exactly(no_recent_sign_in_user)
      end
    end
  end

  describe '#signed_in_recently?' do
    subject { Fabricate.build :user, current_sign_in_at: }

    context 'when current_sign_in_at is nil' do
      let(:current_sign_in_at) { nil }

      it { is_expected.to_not be_signed_in_recently }
    end

    context 'when current_sign_in_at is before the threshold' do
      let(:current_sign_in_at) { 10.days.ago }

      it { is_expected.to_not be_signed_in_recently }
    end

    context 'when current_sign_in_at is after the threshold' do
      let(:current_sign_in_at) { 2.days.ago }

      it { is_expected.to be_signed_in_recently }
    end
  end

  describe '#suspicious_inactive_sign_in?' do
    subject { Fabricate.build :user, current_sign_in_at: }

    context 'when current_sign_in_at is nil' do
      let(:current_sign_in_at) { nil }

      it { is_expected.to_not be_suspicious_inactive_sign_in }
    end

    context 'when current_sign_in_at is before the threshold' do
      let(:current_sign_in_at) { 80.days.ago }

      it { is_expected.to_not be_suspicious_inactive_sign_in }
    end

    context 'when current_sign_in_at is after the threshold' do
      let(:current_sign_in_at) { 91.days.ago }

      it { is_expected.to be_suspicious_inactive_sign_in }
    end

    context 'when the user is external' do
      subject { Fabricate.build :user, password: nil, current_sign_in_at: 7.months.ago }

      it { is_expected.to_not be_suspicious_inactive_sign_in }
    end

    context 'when the otp is required for login' do
      subject { Fabricate.build :user, otp_required_for_login: true, current_sign_in_at: 7.months.ago }

      it { is_expected.to_not be_suspicious_inactive_sign_in }
    end
  end
end
