require 'rails_helper'

RSpec.describe Vacuum::SystemKeysVacuum do
  subject { described_class.new }

  describe '#perform' do
    let!(:expired_system_key) { Fabricate(:system_key, created_at: (SystemKey::ROTATION_PERIOD * 4).ago) }
    let!(:current_system_key) { Fabricate(:system_key) }

    before do
      subject.perform
    end

    it 'deletes the expired key' do
      expect { expired_system_key.reload }.to raise_error ActiveRecord::RecordNotFound
    end

    it 'does not delete the current key' do
      expect { current_system_key.reload }.to_not raise_error
    end
  end
end
