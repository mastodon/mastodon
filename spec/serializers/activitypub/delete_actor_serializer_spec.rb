# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::DeleteActorSerializer do
  subject { serialized_record_json(account, described_class, adapter: ActivityPub::Adapter) }

  let(:tag_manager) { ActivityPub::TagManager.instance }
  let(:account) { Fabricate(:account) }

  it 'serializes to the expected json' do
    expect(subject).to include({
      'id' => "#{tag_manager.uri_for(account)}#delete",
      'type' => 'Delete',
      'actor' => tag_manager.uri_for(account),
      'to' => ['https://www.w3.org/ns/activitystreams#Public'],
      'object' => tag_manager.uri_for(account),
    })

    expect(subject).to_not have_key('published')
    expect(subject).to_not have_key('cc')
    expect(subject).to_not have_key('target')
  end
end
