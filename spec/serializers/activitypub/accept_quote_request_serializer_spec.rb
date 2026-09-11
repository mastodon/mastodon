# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::AcceptQuoteRequestSerializer do
  subject { serialized_record_json(record, described_class, adapter: ActivityPub::Adapter) }

  describe 'serializing an object' do
    let(:record) { Fabricate(:quote, state: :accepted) }

    it 'returns expected attributes' do
      expect(subject.deep_symbolize_keys)
        .to include(
          actor: eq(ActivityPub::TagManager.instance.uri_for(record.quoted_account)),
          id: match("#accepts/quote_requests/#{record.id}"),
          object: include(
            type: 'QuoteRequest',
            instrument: ActivityPub::TagManager.instance.uri_for(record.status),
            object: ActivityPub::TagManager.instance.uri_for(record.quoted_status)
          ),
          type: 'Accept'
        )
    end
  end
end
