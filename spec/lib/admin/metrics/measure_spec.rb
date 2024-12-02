# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::Metrics::Measure do
  describe '.retrieve' do
    subject { described_class.retrieve(reports, start_at, end_at, params) }

    let(:start_at) { 2.days.ago }
    let(:end_at) { Time.now.utc }
    let(:params) { ActionController::Parameters.new({ instance_accounts: [123], instance_followers: [123] }) }
    let(:reports) { [:instance_accounts, :instance_followers] }

    it 'returns instances of provided classes' do
      expect(subject)
        .to contain_exactly(
          be_a(Admin::Metrics::Measure::InstanceAccountsMeasure),
          be_a(Admin::Metrics::Measure::InstanceFollowersMeasure)
        )
    end
  end
end
