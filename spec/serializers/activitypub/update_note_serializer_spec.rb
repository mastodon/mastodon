# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::UpdateNoteSerializer do
  subject { serialized_record_json(status, described_class, adapter: ActivityPub::Adapter) }

  let(:tag_manager) { ActivityPub::TagManager.instance }
  let(:status) { Fabricate(:status, edited_at: Time.utc(2026, 1, 27, 15, 29, 31)) }

  it 'serializes to the expected json' do
    expect(subject).to include({
      'id' => "#{tag_manager.uri_for(status)}#updates/1769527771",
      'type' => 'Update',
      'actor' => tag_manager.uri_for(status.account),
      'published' => '2026-01-27T15:29:31Z',
      'to' => ['https://www.w3.org/ns/activitystreams#Public'],
      'cc' => [a_string_matching(%r{/followers$})],
      'object' => a_hash_including(
        'id' => tag_manager.uri_for(status)
      ),
    })

    expect(subject).to_not have_key('target')
  end
end
