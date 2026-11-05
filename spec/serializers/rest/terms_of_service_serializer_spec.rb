# frozen_string_literal: true

require 'rails_helper'

RSpec.describe REST::TermsOfServiceSerializer do
  subject { serialized_record_json(record, described_class) }

  let(:record) { Fabricate(:terms_of_service, text: 'You must be 100% nice on %{domain}') } # rubocop:disable Style/FormatStringToken

  describe 'serialization' do
    it 'fills in the domain and keeps other percent signs' do
      expect(subject['content'])
        .to eq("<p>You must be 100% nice on #{Rails.configuration.x.local_domain}</p>\n")
    end
  end
end
