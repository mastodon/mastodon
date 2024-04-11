# frozen_string_literal: true

require 'rails_helper'

describe Admin::Metrics::Dimension::SourcesDimension do
  subject { described_class.new(start_at, end_at, limit, params) }

  let(:start_at) { 2.days.ago }
  let(:end_at) { Time.now.utc }
  let(:limit) { 10 }
  let(:params) { ActionController::Parameters.new }

  describe '#data' do
    let(:app) { Fabricate(:application) }
    let(:alice) { Fabricate(:user) }
    let(:bob) { Fabricate(:user) }

    before do
      alice.update(created_by_application: app)
    end

    it 'returns OAuth applications with user counts' do
      expect(subject.data.size)
        .to eq(1)
      expect(subject.data.map(&:symbolize_keys))
        .to contain_exactly(
          include(key: app.name, value: '1')
        )
    end
  end
end
