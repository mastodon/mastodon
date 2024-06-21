# frozen_string_literal: true

require 'rails_helper'

describe Admin::Metrics::Dimension do
  describe '.retrieve' do
    subject { described_class.retrieve(reports, start_at, end_at, 5, params) }

    let(:start_at) { 2.days.ago }
    let(:end_at) { Time.now.utc }
    let(:params) { ActionController::Parameters.new({ instance_accounts: [123], instance_languages: ['en'] }) }
    let(:reports) { [:instance_accounts, :instance_languages] }

    it 'returns instances of provided classes' do
      expect(subject)
        .to contain_exactly(
          be_a(Admin::Metrics::Dimension::InstanceAccountsDimension),
          be_a(Admin::Metrics::Dimension::InstanceLanguagesDimension)
        )
    end
  end
end
