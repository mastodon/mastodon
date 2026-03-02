# frozen_string_literal: true

require 'rails_helper'

RSpec.describe REST::CollectionWithAccountsSerializer do
  subject do
    serialized_record_json(collection, described_class, options: {
      scope: current_user,
      scope_name: :current_user,
    })
  end

  let(:current_user) { nil }

  let(:tag) { Fabricate(:tag, name: 'discovery') }
  let(:accounts) { Fabricate.times(3, :account) }
  let(:collection) do
    Fabricate(:collection,
              account: accounts.first,
              id: 2342,
              name: 'Exquisite follows',
              description: 'Always worth a follow',
              language: 'en',
              local: true,
              sensitive: true,
              discoverable: false,
              tag:)
  end

  before do
    accounts[1..2].each do |account|
      Fabricate(:collection_item, collection:, account:)
    end
    collection.reload
  end

  it 'includes the relevant attributes' do
    expect(subject)
      .to include(
        'accounts' => an_instance_of(Array),
        'collection' => a_hash_including({
          'account_id' => accounts.first.id.to_s,
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
          'item_count' => 2,
          'items' => an_instance_of(Array),
        })
      )
    expect(subject['accounts'].size).to eq 3
  end
end
