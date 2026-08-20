# frozen_string_literal: true

require 'rails_helper'

RSpec.describe REST::CollectionSerializer do
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
              language: 'en',
              local: true,
              sensitive: true,
              discoverable: false,
              tag:)
  end

  it 'includes the relevant attributes' do
    expect(subject)
      .to include(
        'account_id' => collection.account_id.to_s,
        'uri' => include('2342'),
        'id' => '2342',
        'name' => 'Exquisite follows',
        'description' => 'Always worth a follow',
        'language' => 'en',
        'local' => true,
        'sensitive' => true,
        'discoverable' => false,
        'url' => ActivityPub::TagManager.instance.url_for(collection),
        'tag' => a_hash_including('name' => 'discovery'),
        'created_at' => match_api_datetime_format,
        'updated_at' => match_api_datetime_format,
        'item_count' => 0,
        'items' => []
      )
  end

  context 'when the collection is remote' do
    let(:collection) { Fabricate(:remote_collection, description_html: '<p>remote</p>', url: 'https://example.com/c/1') }

    it 'includes the uri' do
      expect(subject).to include('url' => 'https://example.com/c/1')
    end

    it 'includes the html description' do
      expect(subject)
        .to include('description' => '<p>remote</p>')
    end

    context 'when the description contains unwanted HTML' do
      let(:description_html) { '<script>alert("hi!");</script><p>Nice people</p>' }
      let(:collection) { Fabricate(:remote_collection, description_html:) }

      it 'scrubs the HTML' do
        expect(subject).to include('description' => '<p>Nice people</p>')
      end
    end
  end

  context 'when the collection has items in different states' do
    before do
      %i(accepted pending rejected revoked).each do |state|
        Fabricate(:collection_item, collection:, state:)
      end
    end

    context 'when `current_user` is the owner of the collection' do
      let(:current_user) { collection.account.user }

      it 'includes accepted and pending items' do
        expect(subject['item_count']).to eq 2
        expect(subject['items'].size).to eq 2
        expect(subject['items'].pluck('state')).to contain_exactly('accepted', 'pending')
      end
    end

    context 'when `current_user` is not the owner of the collection' do
      it 'only includes the accepted item' do
        expect(subject['item_count']).to eq 1
        expect(subject['items'].size).to eq 1
        expect(subject['items'].first['state']).to eq 'accepted'
      end
    end
  end
end
