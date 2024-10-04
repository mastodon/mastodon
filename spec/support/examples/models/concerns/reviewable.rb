# frozen_string_literal: true

RSpec.shared_examples 'Reviewable' do
  subject { described_class.new(reviewed_at: reviewed_at, requested_review_at: requested_review_at) }

  let(:reviewed_at) { nil }
  let(:requested_review_at) { nil }

  describe 'Scopes' do
    let!(:reviewed_record) { Fabricate factory_name, reviewed_at: 10.days.ago }
    let!(:un_reviewed_record) { Fabricate factory_name, reviewed_at: nil }

    describe '.reviewed' do
      it 'returns reviewed records' do
        expect(described_class.reviewed)
          .to include(reviewed_record)
          .and not_include(un_reviewed_record)
      end
    end

    describe '.unreviewed' do
      it 'returns non reviewed records' do
        expect(described_class.unreviewed)
          .to include(un_reviewed_record)
          .and not_include(reviewed_record)
      end
    end

    def factory_name
      described_class.name.underscore.to_sym
    end
  end

  describe '#requires_review?' do
    it { is_expected.to be_requires_review }

    context 'when reviewed_at is not null' do
      let(:reviewed_at) { 5.days.ago }

      it { is_expected.to_not be_requires_review }
    end
  end

  describe '#reviewed?' do
    it { is_expected.to_not be_reviewed }

    context 'when reviewed_at is not null' do
      let(:reviewed_at) { 5.days.ago }

      it { is_expected.to be_reviewed }
    end
  end

  describe '#requested_review?' do
    it { is_expected.to_not be_requested_review }

    context 'when requested_reviewed_at is not null' do
      let(:requested_review_at) { 5.days.ago }

      it { is_expected.to be_requested_review }
    end
  end

  describe '#requires_review_notification?' do
    it { is_expected.to be_requires_review_notification }

    context 'when reviewed_at is not null' do
      let(:reviewed_at) { 5.days.ago }

      it { is_expected.to_not be_requires_review_notification }
    end

    context 'when requested_reviewed_at is not null' do
      let(:requested_review_at) { 5.days.ago }

      it { is_expected.to_not be_requires_review_notification }
    end
  end
end
