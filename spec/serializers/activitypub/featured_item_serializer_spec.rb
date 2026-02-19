# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::FeaturedItemSerializer do
  subject { serialized_record_json(collection_item, described_class, adapter: ActivityPub::Adapter) }

  let(:collection_item) { Fabricate(:collection_item) }

  it 'serializes to the expected structure' do
    expect(subject).to include({
      'type' => 'FeaturedItem',
      'id' => ActivityPub::TagManager.instance.uri_for(collection_item),
      'featuredObject' => ActivityPub::TagManager.instance.uri_for(collection_item.account),
      'featuredObjectType' => 'Person',
    })
  end
end
