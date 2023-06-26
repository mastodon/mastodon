# frozen_string_literal: true

require 'rails_helper'

describe Admin::Metrics::Dimension::ServersDimension do
  subject(:dimension) { described_class.new(start_at, end_at, limit, params) }

  let(:start_at) { 2.days.ago }
  let(:end_at) { Time.now.utc }
  let(:limit) { 10 }
  let(:params) { ActionController::Parameters.new }

  describe '#data' do
    it 'runs data query without error' do
      expect { dimension.data }.to_not raise_error
    end
  end
end
