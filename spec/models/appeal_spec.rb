# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Appeal do
  describe 'Validations' do
    subject { Fabricate.build :appeal, strike: Fabricate(:account_warning) }

    it { is_expected.to validate_length_of(:text).is_at_most(described_class::TEXT_LENGTH_LIMIT) }
  end

  describe 'scopes' do
    describe 'approved' do
      let(:approved_appeal) { Fabricate(:appeal, approved_at: 10.days.ago) }
      let(:not_approved_appeal) { Fabricate(:appeal, approved_at: nil) }

      it 'finds the correct records' do
        results = described_class.approved
        expect(results).to eq([approved_appeal])
      end
    end

    describe 'rejected' do
      let(:rejected_appeal) { Fabricate(:appeal, rejected_at: 10.days.ago) }
      let(:not_rejected_appeal) { Fabricate(:appeal, rejected_at: nil) }

      it 'finds the correct records' do
        results = described_class.rejected
        expect(results).to eq([rejected_appeal])
      end
    end

    describe 'pending' do
      let(:approved_appeal) { Fabricate(:appeal, approved_at: 10.days.ago) }
      let(:rejected_appeal) { Fabricate(:appeal, rejected_at: 10.days.ago) }
      let(:pending_appeal) { Fabricate(:appeal, rejected_at: nil, approved_at: nil) }

      it 'finds the correct records' do
        results = described_class.pending
        expect(results).to eq([pending_appeal])
      end
    end
  end
end
