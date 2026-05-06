# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::FollowSerializer do
  subject { serialized_record_json(follow, described_class, adapter: ActivityPub::Adapter) }

  let(:tag_manager) { ActivityPub::TagManager.instance }
  let(:follow) { Fabricate(:follow, uri: 'https://localhost/follow/1') }

  it 'serializes to the expected json' do
    expect(subject).to include({
      'id' => 'https://localhost/follow/1',
      'type' => 'Follow',
      'actor' => tag_manager.uri_for(follow.account),
      'object' => tag_manager.uri_for(follow.target_account),
    })

    expect(subject).to_not have_key('published')
    expect(subject).to_not have_key('to')
    expect(subject).to_not have_key('cc')
    expect(subject).to_not have_key('target')
  end
end
