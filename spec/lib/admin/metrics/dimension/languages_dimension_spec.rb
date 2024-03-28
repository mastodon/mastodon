# frozen_string_literal: true

require 'rails_helper'

describe Admin::Metrics::Dimension::LanguagesDimension do
  subject { described_class.new(start_at, end_at, limit, params) }

  let(:start_at) { 2.days.ago }
  let(:end_at) { Time.now.utc }
  let(:limit) { 10 }
  let(:params) { ActionController::Parameters.new }

  describe '#data' do
    let(:alice) { Fabricate(:user, locale: 'en', current_sign_in_at: 1.day.ago) }
    let(:bob) { Fabricate(:user, locale: 'en', current_sign_in_at: 30.days.ago) }

    before do
      alice.update(current_sign_in_at: 1.day.ago)
      bob.update(current_sign_in_at: 30.days.ago)
    end

    it 'returns locales with sign in counts' do
      expect(subject.data.size)
        .to eq(1)
      expect(subject.data.map(&:symbolize_keys))
        .to contain_exactly(
          include(key: 'en', value: '1')
        )
    end
  end
end
