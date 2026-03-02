# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::RemoveFeaturedItemSerializer do
  subject { serialized_record_json(object, described_class, adapter: ActivityPub::Adapter) }

  let(:tag_manager) { ActivityPub::TagManager.instance }
  let(:collection) { Fabricate(:collection) }
  let(:object) { Fabricate(:collection_item, collection:) }

  it 'serializes to the expected json' do
    expect(subject).to include({
      'type' => 'Remove',
      'actor' => tag_manager.uri_for(collection.account),
      'target' => tag_manager.uri_for(collection),
      'object' => tag_manager.uri_for(object),
    })

    expect(subject).to_not have_key('id')
    expect(subject).to_not have_key('published')
    expect(subject).to_not have_key('to')
    expect(subject).to_not have_key('cc')
  end
end
