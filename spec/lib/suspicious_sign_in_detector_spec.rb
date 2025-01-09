# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SuspiciousSignInDetector do
  describe '#suspicious?' do
    subject { described_class.new(user).suspicious?(request) }

    let(:user) { Fabricate(:user, current_sign_in_at: 1.day.ago) }
    let(:request) { instance_double(ActionDispatch::Request, remote_ip: remote_ip) }
    let(:remote_ip) { nil }

    context 'when user has 2FA enabled' do
      before do
        user.update!(otp_required_for_login: true)
      end

      it 'returns false' do
        expect(subject).to be false
      end
    end

    context 'when exact IP has been used before' do
      let(:remote_ip) { '1.1.1.1' }

      before do
        user.update!(sign_up_ip: remote_ip)
      end

      it 'returns false' do
        expect(subject).to be false
      end
    end

    context 'when similar IP has been used before' do
      let(:remote_ip) { '1.1.2.2' }

      before do
        user.update!(sign_up_ip: '1.1.1.1')
      end

      it 'returns false' do
        expect(subject).to be false
      end
    end

    context 'when IP is completely unfamiliar' do
      let(:remote_ip) { '2.2.2.2' }

      before do
        user.update!(sign_up_ip: '1.1.1.1')
      end

      it 'returns true' do
        expect(subject).to be true
      end
    end
  end
end
