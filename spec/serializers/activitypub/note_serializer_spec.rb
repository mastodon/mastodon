# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::NoteSerializer do
  subject { serialized_record_json(parent, described_class, adapter: ActivityPub::Adapter) }

  let!(:account) { Fabricate(:account) }
  let!(:other) { Fabricate(:account) }
  let!(:parent) { Fabricate(:status, account: account, visibility: :public, language: 'zh-TW') }
  let!(:reply_by_account_first) { Fabricate(:status, account: account, thread: parent, visibility: :public) }
  let!(:reply_by_account_next) { Fabricate(:status, account: account, thread: parent, visibility: :public) }
  let!(:reply_by_other_first) { Fabricate(:status, account: other, thread: parent, visibility: :public) }
  let!(:reply_by_account_third) { Fabricate(:status, account: account, thread: parent, visibility: :public) }
  let!(:reply_by_account_visibility_direct) { Fabricate(:status, account: account, thread: parent, visibility: :direct) }

  it 'has the expected shape and replies collection' do
    expect(subject).to include({
      '@context' => include('https://www.w3.org/ns/activitystreams'),
      'type' => 'Note',
      'attributedTo' => ActivityPub::TagManager.instance.uri_for(account),
      'contentMap' => include({
        'zh-TW' => a_kind_of(String),
      }),
      'replies' => replies_collection_values,
      'context' => ActivityPub::TagManager.instance.uri_for(parent.conversation),
    })
  end

  def replies_collection_values
    include(
      'type' => eql('Collection'),
      'first' => include(
        'type' => eql('CollectionPage'),
        'items' => reply_items
      )
    )
  end

  def reply_items
    include(reply_by_account_first.uri, reply_by_account_next.uri, reply_by_account_third.uri) # Public self replies
      .and(not_include(reply_by_other_first.uri)) # Replies from others
      .and(not_include(reply_by_account_visibility_direct.uri)) # Replies with direct visibility
  end

  context 'with a quote' do
    let(:quoted_status) { Fabricate(:status) }
    let!(:quote) { Fabricate(:quote, status: parent, quoted_status: quoted_status, state: :accepted) }

    it 'has the expected shape' do
      expect(subject).to include({
        'type' => 'Note',
        'quote' => ActivityPub::TagManager.instance.uri_for(quote.quoted_status),
        'quoteUri' => ActivityPub::TagManager.instance.uri_for(quote.quoted_status),
        '_misskey_quote' => ActivityPub::TagManager.instance.uri_for(quote.quoted_status),
        'quoteAuthorization' => ActivityPub::TagManager.instance.approval_uri_for(quote),
      })
    end
  end

  context 'with a deleted quote' do
    let(:quoted_status) { Fabricate(:status) }

    before do
      Fabricate(:quote, status: parent, quoted_status: nil, state: :accepted)
    end

    it 'has the expected shape' do
      expect(subject).to include({
        'type' => 'Note',
        'quote' => { 'type' => 'Tombstone' },
      })
    end
  end

  context 'with a quote policy' do
    let(:parent) { Fabricate(:status, quote_approval_policy: InteractionPolicy::POLICY_FLAGS[:followers] << 16) }

    it 'has the expected shape' do
      expect(subject).to include({
        'type' => 'Note',
        'interactionPolicy' => a_hash_including(
          'canQuote' => a_hash_including(
            'automaticApproval' => [ActivityPub::TagManager.instance.followers_uri_for(parent.account)]
          )
        ),
      })
    end
  end
end
