require 'rails_helper'

RSpec.describe Poll, type: :model do
  describe '#final?' do
    subject { described_class.new }

    context 'for local polls' do
      before do
        allow(subject).to receive(:local?) { true }
      end

      context 'when not expired' do
        it do
          expect(subject).to receive(:expired?) { false }
          expect(subject.final?).to eq false
        end
      end

      context 'when expired' do
        it do
          expect(subject).to receive(:expired?) { true }
          expect(subject.final?).to eq true
        end
      end
    end

    context 'for remote polls' do
      before do
        allow(subject).to receive(:local?) { false }
      end

      context 'when not expired' do
        it do
          expect(subject).to receive(:expired?) { false }
          expect(subject.final?).to eq false
        end
      end

      context 'when expired' do
        before do
          expect(subject).to receive(:expired?) { true }
        end

        it 'fetched before expiration' do
          expect(subject).to receive(:fetched_after_expiration?) { false }
          expect(subject.final?).to eq false
        end

        it 'fetched after expiration' do
          expect(subject).to receive(:fetched_after_expiration?) { true }
          expect(subject.final?).to eq true
        end
      end
    end
  end

  describe '#fetched_after_expiration?' do
    subject { described_class.new }

    it 'fetched before expiration' do
      subject.expires_at = 5.minute.ago
      subject.last_fetched_at = 10.minute.ago

      expect(subject.send(:fetched_after_expiration?)).to eq false
    end

    it 'fetched after expiration' do
      subject.expires_at = 5.minute.ago
      subject.last_fetched_at = 1.minute.ago

      expect(subject.send(:fetched_after_expiration?)).to eq true
    end

    it 'never expires' do
      subject.expires_at = nil
      subject.last_fetched_at = 1.minute.ago

      expect(subject.send(:fetched_after_expiration?)).to eq false
    end

    it 'not fetched' do
      subject.expires_at = 5.minutes.ago
      subject.last_fetched_at = nil

      expect(subject.send(:fetched_after_expiration?)).to eq false
    end
  end
end
