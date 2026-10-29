# frozen_string_literal: true

require 'rails_helper'

RSpec.describe REST::PrivacyPolicySerializer do
  subject { serialized_record_json(record, described_class) }

  let(:record) { PrivacyPolicy.new(text: '100% of the data on %{domain} stays here', updated_at: Time.zone.now) } # rubocop:disable Style/FormatStringToken

  describe 'serialization' do
    it 'fills in the domain and keeps other percent signs' do
      expect(subject['content'])
        .to eq("<p>100% of the data on #{Rails.configuration.x.local_domain} stays here</p>\n")
    end
  end
end
