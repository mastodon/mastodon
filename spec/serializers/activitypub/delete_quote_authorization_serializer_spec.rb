# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::DeleteQuoteAuthorizationSerializer do
  subject { serialized_record_json(quote, described_class, adapter: ActivityPub::Adapter) }

  describe 'serializing an object' do
    let(:status) { Fabricate(:status) }
    let(:quote) { Fabricate(:quote, quoted_status: status, state: :accepted, approval_uri: "https://#{Rails.configuration.x.web_domain}/approvals/1234") }

    it 'returns expected attributes' do
      expect(subject.deep_symbolize_keys)
        .to include(
          actor: eq(ActivityPub::TagManager.instance.uri_for(status.account)),
          object: quote.approval_uri,
          type: 'Delete'
        )
    end
  end
end
