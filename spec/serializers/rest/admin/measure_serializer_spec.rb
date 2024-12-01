# frozen_string_literal: true

require 'rails_helper'

RSpec.describe REST::Admin::MeasureSerializer, pending: 'broken' do
  subject { serialized_record_json(record, described_class) }

  let(:start_at) { 2.days.ago }
  let(:end_at) { Time.now.utc }
  let(:params) { ActionController::Parameters.new({ instance_accounts: [123] }) }
  let(:reports) { [:instance_accounts] }
  let(:record) { Admin::Metrics::Measure.retrieve(reports, start_at, end_at, params) }

  context 'when start_at is populated' do
    it 'parses as RFC 3339 datetime' do
      p subject[0]
      expect { DateTime.rfc3339(subject[0]['@start_at']) }.to_not raise_error
    end
  end
end
