# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::UndoAnnounceSerializer do
  subject { serialized_record_json(reblog, described_class, adapter: ActivityPub::Adapter) }

  let(:tag_manager) { ActivityPub::TagManager.instance }
  let(:status) { Fabricate(:status) }
  let(:reblog) { Fabricate(:status, reblog: status) }

  it 'serializes to the expected json' do
    expect(subject).to include({
      'id' => "#{tag_manager.uri_for(reblog.account)}#announces/#{reblog.id}/undo",
      'type' => 'Undo',
      'actor' => tag_manager.uri_for(reblog.account),
      'to' => ['https://www.w3.org/ns/activitystreams#Public'],
      'object' => a_hash_including({
        'id' => tag_manager.activity_uri_for(reblog),
        'type' => 'Announce',
        'object' => tag_manager.uri_for(status),
      }),
    })

    expect(subject).to_not have_key('published')
    expect(subject).to_not have_key('cc')
    expect(subject).to_not have_key('target')
  end

  context 'when status is local and private' do
    let(:status) { Fabricate(:status, visibility: :private) }
    let(:reblog) { Fabricate(:status, reblog: status, account: status.account) }

    it 'does not inline the status' do
      expect(subject).to include({
        'object' => a_hash_including({
          'object' => tag_manager.uri_for(status),
        }),
      })
    end
  end
end
