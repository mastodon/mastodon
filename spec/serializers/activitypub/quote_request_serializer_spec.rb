# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::QuoteRequestSerializer do
  subject { serialized_record_json(quote, described_class, adapter: ActivityPub::Adapter, options: { allow_post_inlining: inlining }) }

  let(:tag_manager) { ActivityPub::TagManager.instance }
  let(:quote) { Fabricate(:quote) }

  context 'without inlining' do
    let(:inlining) { false }

    it 'serializes to the expected json' do
      expect(subject).to include({
        'id' => quote.activity_uri,
        'type' => 'QuoteRequest',
        'actor' => tag_manager.uri_for(quote.account),
        'instrument' => tag_manager.uri_for(quote.status),
        'object' => tag_manager.uri_for(quote.quoted_status),
      })

      expect(subject).to_not have_key('published')
      expect(subject).to_not have_key('to')
      expect(subject).to_not have_key('cc')
      expect(subject).to_not have_key('target')
    end
  end

  context 'with inlining' do
    let(:inlining) { true }

    it 'serializes to the expected json' do
      expect(subject).to include({
        'id' => quote.activity_uri,
        'type' => 'QuoteRequest',
        'actor' => tag_manager.uri_for(quote.account),
        'instrument' => a_hash_including({
          'id' => tag_manager.uri_for(quote.status),
          'type' => 'Note',
        }),
        'object' => tag_manager.uri_for(quote.quoted_status),
      })

      expect(subject).to_not have_key('published')
      expect(subject).to_not have_key('to')
      expect(subject).to_not have_key('cc')
      expect(subject).to_not have_key('target')
    end
  end
end
