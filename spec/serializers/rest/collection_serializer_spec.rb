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
        'tag' => a_hash_including('name' => 'discovery'),
        'created_at' => match_api_datetime_format,
        'updated_at' => match_api_datetime_format,
        'item_count' => 0,
        'items' => []
      )
  end

  context 'when the collection is remote' do
    let(:collection) { Fabricate(:remote_collection, description_html: '<p>remote</p>') }

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
end
