# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Appeal do
  describe 'Validations' do
    subject { Fabricate.build :appeal, strike: Fabricate(:account_warning) }

    it { is_expected.to validate_length_of(:text).is_at_most(described_class::TEXT_LENGTH_LIMIT) }

    context 'with a strike created too long ago' do
      let(:strike) { Fabricate.build :account_warning, created_at: 100.days.ago }

      it { is_expected.to_not allow_values(strike).for(:strike).against(:base).on(:create) }
    end
  end

  describe 'Query methods' do
    describe '#pending?' do
      subject { Fabricate.build :appeal, approved_at:, rejected_at: }

      context 'with not approved and not rejected' do
        let(:approved_at) { nil }
        let(:rejected_at) { nil }

        it { expect(subject).to be_pending }
      end

      context 'with approved and rejected' do
        let(:approved_at) { 1.day.ago }
        let(:rejected_at) { 1.day.ago }

        it { expect(subject).to_not be_pending }
      end

      context 'with approved and not rejected' do
        let(:approved_at) { 1.day.ago }
        let(:rejected_at) { nil }

        it { expect(subject).to_not be_pending }
      end

      context 'with not approved and rejected' do
        let(:approved_at) { nil }
        let(:rejected_at) { 1.day.ago }

        it { expect(subject).to_not be_pending }
      end
    end

    describe '#approved?' do
      subject { Fabricate.build :appeal, approved_at: }

      context 'with not approved' do
        let(:approved_at) { nil }

        it { expect(subject).to_not be_approved }
      end

      context 'with approved' do
        let(:approved_at) { 1.day.ago }

        it { expect(subject).to be_approved }
      end
    end

    describe '#rejected?' do
      subject { Fabricate.build :appeal, rejected_at: }

      context 'with not rejected' do
        let(:rejected_at) { nil }

        it { expect(subject).to_not be_rejected }
      end

      context 'with rejected' do
        let(:rejected_at) { 1.day.ago }

        it { expect(subject).to be_rejected }
      end
    end
  end

  describe 'Scopes' do
    describe '.approved' do
      let(:approved_appeal) { Fabricate(:appeal, approved_at: 10.days.ago) }
      let(:not_approved_appeal) { Fabricate(:appeal, approved_at: nil) }

      it 'finds the correct records' do
        results = described_class.approved
        expect(results).to eq([approved_appeal])
      end
    end

    describe '.rejected' do
      let(:rejected_appeal) { Fabricate(:appeal, rejected_at: 10.days.ago) }
      let(:not_rejected_appeal) { Fabricate(:appeal, rejected_at: nil) }

      it 'finds the correct records' do
        results = described_class.rejected
        expect(results).to eq([rejected_appeal])
      end
    end

    describe '.pending' do
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
