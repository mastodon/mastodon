# frozen_string_literal: true

RSpec.shared_examples 'Reviewable' do
  subject { described_class.new(reviewed_at: reviewed_at, requested_review_at: requested_review_at) }

  let(:reviewed_at) { nil }
  let(:requested_review_at) { nil }

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
