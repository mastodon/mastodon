# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User::SignInToken do
  describe '#valid_sign_in_token?' do
    subject { Fabricate.build(:user) }

    before { subject.generate_sign_in_token }

    context 'when the token is random' do
      let(:token) { Devise.friendly_token(6) }

      it { expect(subject.valid_sign_in_token?(token)).to be false }
    end

    context 'when the token is the same' do
      let(:token) { subject.sign_in_token }

      it { expect(subject.valid_sign_in_token?(token)).to be true }
    end
  end

  describe '#suspicious_inactive_sign_in?' do
    subject { Fabricate.build(:user, current_sign_in_at:) }

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
      subject { Fabricate.build(:user, password: nil, current_sign_in_at: 7.months.ago) }

      it { is_expected.to_not be_suspicious_inactive_sign_in }
    end

    context 'when the otp is required for login' do
      subject { Fabricate.build(:user, otp_required_for_login: true, current_sign_in_at: 7.months.ago) }

      it { is_expected.to_not be_suspicious_inactive_sign_in }
    end
  end

  describe '#generate_sign_in_token' do
    subject { Fabricate(:user) }

    before { subject.generate_sign_in_token }

    it 'generates a new sign in token' do
      expect(subject.sign_in_token).to_not be_nil
      expect(subject.sign_in_token_sent_at).to_not be_nil
    end
  end

  describe '#disable_sign_in_token!' do
    subject { Fabricate(:user, current_sign_in_at: 95.days.ago) }

    before { subject.disable_sign_in_token! }

    it { is_expected.to_not be_suspicious_inactive_sign_in }
  end
end
