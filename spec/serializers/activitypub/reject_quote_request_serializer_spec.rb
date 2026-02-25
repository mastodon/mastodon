# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::RejectQuoteRequestSerializer do
  subject { serialized_record_json(quote, described_class, adapter: ActivityPub::Adapter) }

  let(:tag_manager) { ActivityPub::TagManager.instance }
  let(:quote) { Fabricate(:quote) }

  it 'serializes to the expected json' do
    expect(subject).to include({
      'id' => "#{tag_manager.uri_for(quote.quoted_account)}#rejects/quote_requests/#{quote.id}",
      'type' => 'Reject',
      'actor' => tag_manager.uri_for(quote.quoted_account),
      'object' => a_hash_including({
        'id' => quote.activity_uri,
        'type' => 'QuoteRequest',
      }),
    })

    expect(subject).to_not have_key('published')
    expect(subject).to_not have_key('to')
    expect(subject).to_not have_key('cc')
    expect(subject).to_not have_key('target')
  end
end
