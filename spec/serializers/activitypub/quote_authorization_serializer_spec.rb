# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::QuoteAuthorizationSerializer do
  subject { serialized_record_json(quote, described_class, adapter: ActivityPub::Adapter) }

  describe 'serializing an object' do
    let(:status) { Fabricate(:status) }
    let(:quote) { Fabricate(:quote, quoted_status: status, state: :accepted) }

    it 'returns expected attributes' do
      expect(subject.deep_symbolize_keys)
        .to include(
          attributedTo: eq(ActivityPub::TagManager.instance.uri_for(status.account)),
          interactionTarget: ActivityPub::TagManager.instance.uri_for(status),
          interactingObject: ActivityPub::TagManager.instance.uri_for(quote.status),
          type: 'QuoteAuthorization'
        )
    end
  end
end
