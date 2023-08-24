# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SessionActivation do
  describe '#detection' do
    let(:session_activation) { Fabricate(:session_activation, user_agent: 'Chrome/62.0.3202.89') }

    it 'sets a Browser instance as detection' do
      expect(session_activation.detection).to be_a Browser::Chrome
    end
  end

  describe '#browser' do
    before do
      allow(session_activation).to receive(:detection).and_return(detection)
    end

    let(:detection)          { instance_double(Browser::Chrome, id: 1) }
    let(:session_activation) { Fabricate(:session_activation) }

    it 'returns detection.id' do
      expect(session_activation.browser).to be 1
    end
  end

  describe '#platform' do
    before do
      allow(session_activation).to receive(:detection).and_return(detection)
    end

    let(:session_activation) { Fabricate(:session_activation) }
    let(:detection)          { instance_double(Browser::Chrome, platform: instance_double(Browser::Platform, id: 1)) }

    it 'returns detection.platform.id' do
      expect(session_activation.platform).to be 1
    end
  end

  describe '.active?' do
    subject { described_class.active?(id) }

    context 'when id is absent' do
      let(:id) { nil }

      it 'returns nil' do
        expect(subject).to be_nil
      end
    end

    context 'when id is present' do
      let(:id) { '1' }
      let!(:session_activation) { Fabricate(:session_activation, session_id: id) }

      context 'when id exists as session_id' do
        it 'returns true' do
          expect(subject).to be true
        end
      end

      context 'when id does not exist as session_id' do
        before do
          session_activation.update!(session_id: '2')
        end

        it 'returns false' do
          expect(subject).to be false
        end
      end
    end
  end

  describe '.activate' do
    let(:options) { { user: Fabricate(:user), session_id: '1' } }

    it 'calls create! and purge_old' do
      expect(described_class).to receive(:create!).with(**options)
      expect(described_class).to receive(:purge_old)
      described_class.activate(**options)
    end

    it 'returns an instance of SessionActivation' do
      expect(described_class.activate(**options)).to be_a described_class
    end
  end

  describe '.deactivate' do
    context 'when id is absent' do
      let(:id) { nil }

      it 'returns nil' do
        expect(described_class.deactivate(id)).to be_nil
      end
    end

    context 'when id exists' do
      let(:id) { '1' }

      it 'calls where.destroy_all' do
        expect(described_class).to receive_message_chain(:where, :destroy_all)
          .with(session_id: id).with(no_args)

        described_class.deactivate(id)
      end
    end
  end

  describe '.purge_old' do
    it 'calls order.offset.destroy_all' do
      expect(described_class).to receive_message_chain(:order, :offset, :destroy_all)
        .with('created_at desc').with(Rails.configuration.x.max_session_activations).with(no_args)

      described_class.purge_old
    end
  end

  describe '.exclusive' do
    let(:id) { '1' }

    it 'calls where.destroy_all' do
      expect(described_class).to receive_message_chain(:where, :not, :destroy_all)
        .with(session_id: id).with(no_args)

      described_class.exclusive(id)
    end
  end
end
