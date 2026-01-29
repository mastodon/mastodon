# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::AnnounceNoteSerializer do
  subject { serialized_record_json(reblog, described_class, adapter: ActivityPub::Adapter, options:) }

  let(:tag_manager) { ActivityPub::TagManager.instance }
  let(:status) { Fabricate(:status, created_at: Time.utc(2026, 1, 27, 15, 29, 31)) }
  let(:reblog) { Fabricate(:status, reblog: status, created_at: Time.utc(2026, 1, 27, 16, 21, 44)) }
  let(:options) { {} }

  it 'serializes to the expected json' do
    expect(subject).to include({
      'id' => tag_manager.activity_uri_for(reblog),
      'type' => 'Announce',
      'actor' => tag_manager.uri_for(reblog.account),
      'published' => '2026-01-27T16:21:44Z',
      'to' => ['https://www.w3.org/ns/activitystreams#Public'],
      'cc' => [tag_manager.uri_for(status.account), a_string_matching(/followers$/)],
      'object' => tag_manager.uri_for(status),
    })

    expect(subject).to_not have_key('target')
  end

  context 'when inlining of private local status is allowed' do
    let(:status) { Fabricate(:status, visibility: :private, created_at: Time.utc(2026, 1, 27, 15, 29, 31)) }
    let(:reblog) { Fabricate(:status, reblog: status, account: status.account, created_at: Time.utc(2026, 1, 27, 16, 21, 44)) }
    let(:options) { { allow_inlining: true } }

    it 'serializes to the expected json' do
      expect(subject).to include({
        'id' => tag_manager.activity_uri_for(reblog),
        'type' => 'Announce',
        'actor' => tag_manager.uri_for(reblog.account),
        'published' => '2026-01-27T16:21:44Z',
        'to' => ['https://www.w3.org/ns/activitystreams#Public'],
        'cc' => [tag_manager.uri_for(status.account), a_string_matching(/followers$/)],
        'object' => a_hash_including(
          'id' => tag_manager.uri_for(status)
        ),
      })

      expect(subject).to_not have_key('target')
    end
  end
end
