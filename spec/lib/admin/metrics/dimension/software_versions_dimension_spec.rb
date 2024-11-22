# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::Metrics::Dimension::SoftwareVersionsDimension do
  subject { described_class.new(start_at, end_at, limit, params) }

  let(:start_at) { 2.days.ago }
  let(:end_at) { Time.now.utc }
  let(:limit) { 10 }
  let(:params) { ActionController::Parameters.new }

  describe '#data' do
    it 'reports on the running software' do
      expect(subject.data.map(&:symbolize_keys))
        .to include(
          include(key: 'mastodon', value: Mastodon::Version.to_s),
          include(key: 'ruby', value: include(RUBY_VERSION))
        )
    end
  end
end
