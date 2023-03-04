# frozen_string_literal: true

require 'rails_helper'

describe Poll do
  describe 'scopes' do
    let(:status) { Fabricate(:status) }
    let(:attached_poll) { Fabricate(:poll, status: status) }
    let(:not_attached_poll) do
      Fabricate(:poll).tap do |poll|
        poll.status = nil
        poll.save(validate: false)
      end
    end

    describe 'attached' do
      it 'finds the correct records' do
        results = described_class.attached

        expect(results).to eq([attached_poll])
      end
    end

    describe 'unattached' do
      it 'finds the correct records' do
        results = described_class.unattached

        expect(results).to eq([not_attached_poll])
      end
    end
  end

  describe '#final?' do
    subject(:poll) { described_class.new(account: Account.new) }

    context 'when poll is local' do
      it 'returns false when not expired' do
        expect(poll.final?).to be false
      end

      it 'returns true when expired' do
        poll.expires_at = 5.minutes.ago
        expect(poll.final?).to be true
      end
    end

    context 'when poll is remote' do
      before do
        poll.account.domain = 'example.com'
      end

      it 'returns false if not expired' do
        expect(poll.final?).to be false
      end

      it 'returns false if fetched before expiration' do
        poll.expires_at = 5.minutes.ago
        poll.last_fetched_at = 10.minutes.ago
        expect(poll.final?).to be false
      end

      it 'returns true if fetched after expiration' do
        poll.expires_at = 5.minutes.ago
        poll.last_fetched_at = 1.minute.ago
        expect(poll.final?).to be true
      end
    end
  end
end
