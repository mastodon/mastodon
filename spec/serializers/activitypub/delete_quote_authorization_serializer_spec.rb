# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::DeleteQuoteAuthorizationSerializer do
  subject { serialized_record_json(quote, described_class, adapter: ActivityPub::Adapter) }

  describe 'serializing an object' do
    let(:status) { Fabricate(:status) }
    let(:quote) { Fabricate(:quote, quoted_status: status, state: :accepted) }

    it 'returns expected attributes' do
      expect(subject.deep_symbolize_keys)
        .to include(
          actor: eq(ActivityPub::TagManager.instance.uri_for(status.account)),
          object: a_hash_including(
            type: 'QuoteAuthorization',
            id: ActivityPub::TagManager.instance.approval_uri_for(quote, check_approval: false)
          ),
          type: 'Delete'
        )
    end
  end
end
