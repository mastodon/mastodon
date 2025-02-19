# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CustomFilter do
  include_examples 'Expireable'

  describe 'Validations' do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:context) }

    it { is_expected.to_not allow_values([], %w(invalid)).for(:context) }
    it { is_expected.to allow_values(%w(home)).for(:context) }
  end

  describe 'Normalizations' do
    describe 'context' do
      it { is_expected.to normalize(:context).from(['home', 'notifications', 'public    ', '']).to(%w(home notifications public)) }
    end
  end

  describe '#expires_in' do
    subject { custom_filter.expires_in }

    let(:custom_filter) { Fabricate.build(:custom_filter, expires_at: expires_at) }

    context 'when expires_at is nil' do
      let(:expires_at) { nil }

      it { is_expected.to be_nil }
    end

    context 'when expires is beyond the end of the range' do
      let(:expires_at) { described_class::EXPIRATION_DURATIONS.last.from_now + 2.days }

      it { is_expected.to be_nil }
    end

    context 'when expires is before the start of the range' do
      let(:expires_at) { described_class::EXPIRATION_DURATIONS.first.from_now - 10.minutes }

      it { is_expected.to eq(described_class::EXPIRATION_DURATIONS.first) }
    end
  end
end
