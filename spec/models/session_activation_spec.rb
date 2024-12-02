# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SessionActivation do
  include_examples 'BrowserDetection'

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
      allow(described_class).to receive(:create!).with(**options)
      allow(described_class).to receive(:purge_old)

      described_class.activate(**options)

      expect(described_class).to have_received(:create!).with(**options)
      expect(described_class).to have_received(:purge_old)
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
      let!(:session_activation) { Fabricate(:session_activation) }

      it 'destroys the record' do
        described_class.deactivate(session_activation.session_id)

        expect { session_activation.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe '.purge_old' do
    around do |example|
      before = Rails.configuration.x.max_session_activations
      Rails.configuration.x.max_session_activations = 1
      example.run
      Rails.configuration.x.max_session_activations = before
    end

    let!(:oldest_session_activation) { Fabricate(:session_activation, created_at: 10.days.ago) }
    let!(:newest_session_activation) { Fabricate(:session_activation, created_at: 5.days.ago) }

    it 'preserves the newest X records based on config' do
      described_class.purge_old

      expect { oldest_session_activation.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect { newest_session_activation.reload }.to_not raise_error
    end
  end

  describe '.exclusive' do
    let!(:unwanted_session_activation) { Fabricate(:session_activation) }
    let!(:wanted_session_activation) { Fabricate(:session_activation) }

    it 'preserves supplied record and destroys all others' do
      described_class.exclusive(wanted_session_activation.session_id)

      expect { unwanted_session_activation.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect { wanted_session_activation.reload }.to_not raise_error
    end
  end
end
