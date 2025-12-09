# frozen_string_literal: true

require 'rails_helper'

RSpec.describe REST::BaseCollectionSerializer do
  subject do
    serialized_record_json(collection, described_class, options: {
      scope: current_user,
      scope_name: :current_user,
    })
  end

  let(:current_user) { nil }

  let(:tag) { Fabricate(:tag, name: 'discovery') }
  let(:collection) do
    Fabricate(:collection,
              id: 2342,
              name: 'Exquisite follows',
              description: 'Always worth a follow',
              local: true,
              sensitive: true,
              discoverable: false,
              tag:)
  end

  it 'includes the relevant attributes' do
    expect(subject)
      .to include(
        'id' => '2342',
        'name' => 'Exquisite follows',
        'description' => 'Always worth a follow',
        'local' => true,
        'sensitive' => true,
        'discoverable' => false,
        'tag' => a_hash_including('name' => 'discovery'),
        'created_at' => match_api_datetime_format,
        'updated_at' => match_api_datetime_format
      )
  end

  describe 'Counting items' do
    before do
      Fabricate.times(2, :collection_item, collection:)
    end

    it 'can count items on demand' do
      expect(subject['item_count']).to eq 2
    end

    it 'can use precalculated counts' do
      collection.define_singleton_method :item_count, -> { 8 }

      expect(subject['item_count']).to eq 8
    end
  end
end
