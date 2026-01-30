# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::DeleteNoteSerializer do
  subject { serialized_record_json(status, described_class, adapter: ActivityPub::Adapter) }

  let(:tag_manager) { ActivityPub::TagManager.instance }
  let(:status) { Fabricate(:status) }

  it 'serializes to the expected json' do
    expect(subject).to include({
      'id' => "#{tag_manager.uri_for(status)}#delete",
      'type' => 'Delete',
      'actor' => tag_manager.uri_for(status.account),
      'to' => ['https://www.w3.org/ns/activitystreams#Public'],
      'object' => a_hash_including({
        'id' => tag_manager.uri_for(status),
        'type' => 'Tombstone',
      }),
    })

    expect(subject).to_not have_key('published')
    expect(subject).to_not have_key('cc')
    expect(subject).to_not have_key('target')
  end
end
