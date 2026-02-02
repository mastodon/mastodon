# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::LikeSerializer do
  subject { serialized_record_json(favourite, described_class, adapter: ActivityPub::Adapter) }

  let(:tag_manager) { ActivityPub::TagManager.instance }
  let(:favourite) { Fabricate(:favourite) }

  it 'serializes to the expected json' do
    expect(subject).to include({
      'id' => "#{tag_manager.uri_for(favourite.account)}#likes/#{favourite.id}",
      'type' => 'Like',
      'actor' => tag_manager.uri_for(favourite.account),
      'object' => tag_manager.uri_for(favourite.status),
    })

    expect(subject).to_not have_key('published')
    expect(subject).to_not have_key('to')
    expect(subject).to_not have_key('cc')
    expect(subject).to_not have_key('target')
  end
end
