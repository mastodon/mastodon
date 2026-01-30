# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::UpdateActorSerializer do
  subject { serialized_record_json(account, described_class, adapter: ActivityPub::Adapter) }

  let(:tag_manager) { ActivityPub::TagManager.instance }
  let(:account) { Fabricate(:account) }

  it 'serializes to the expected json' do
    expect(subject).to include({
      'id' => "#{tag_manager.uri_for(account)}#updates/#{account.updated_at.to_i}",
      'type' => 'Update',
      'actor' => tag_manager.uri_for(account),
      'to' => ['https://www.w3.org/ns/activitystreams#Public'],
      'object' => a_hash_including({
        'id' => tag_manager.uri_for(account),
        'type' => 'Person',
      }),
    })

    expect(subject).to_not have_key('published')
    expect(subject).to_not have_key('cc')
    expect(subject).to_not have_key('target')
  end
end
