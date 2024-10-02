# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Poll do
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

  describe 'validations' do
    context 'when not valid' do
      subject { Fabricate.build(:poll) }

      it { is_expected.to validate_presence_of(:expires_at) }
    end
  end
end
