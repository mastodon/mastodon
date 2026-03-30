# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::FeatureRequestSerializer do
  subject { serialized_record_json(collection_item, described_class, adapter: ActivityPub::Adapter) }

  let(:tag_manager) { ActivityPub::TagManager.instance }
  let(:target_account) { Fabricate(:remote_account) }
  let(:collection) { Fabricate(:collection) }
  let(:collection_item) { Fabricate(:collection_item, collection:, account: target_account) }

  it 'serializes to the expected json' do
    expect(subject).to include({
      'id' => collection_item.activity_uri,
      'type' => 'FeatureRequest',
      'instrument' => tag_manager.uri_for(collection_item.collection),
      'object' => tag_manager.uri_for(target_account),
    })

    expect(subject).to_not have_key('published')
    expect(subject).to_not have_key('to')
    expect(subject).to_not have_key('cc')
    expect(subject).to_not have_key('target')
  end
end
