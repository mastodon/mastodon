# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::UndoFollowSerializer do
  subject { serialized_record_json(follow, described_class, adapter: ActivityPub::Adapter) }

  let(:tag_manager) { ActivityPub::TagManager.instance }
  let(:follow) { Fabricate(:follow) }

  it 'serializes to the expected json' do
    expect(subject).to include({
      'id' => "#{tag_manager.uri_for(follow.account)}#follows/#{follow.id}/undo",
      'type' => 'Undo',
      'actor' => tag_manager.uri_for(follow.account),
      'object' => a_hash_including({
        'type' => 'Follow',
      }),
    })

    expect(subject).to_not have_key('published')
    expect(subject).to_not have_key('to')
    expect(subject).to_not have_key('cc')
    expect(subject).to_not have_key('target')
  end
end
