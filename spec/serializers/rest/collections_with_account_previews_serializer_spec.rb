# frozen_string_literal: true

require 'rails_helper'

RSpec.describe REST::CollectionsWithAccountPreviewsSerializer do
  subject do
    serialized_record_json(presenter, described_class, options: {
      scope_name: :current_user, scope: nil
    })
  end

  let(:collection_owner_one) { Fabricate(:account) }
  let(:collection_owner_two) { Fabricate(:account) }
  let(:featured_account) { Fabricate(:account) }
  let(:collection_one) do
    Fabricate(:collection,
              account: collection_owner_one,
              name: 'Exquisite follows')
  end
  let(:collection_two) do
    Fabricate(:collection,
              account: collection_owner_two,
              name: 'Excellent people')
  end
  let(:collections) { [collection_one, collection_two] }
  let(:presenter) { CollectionsPresenter.new(collections:) }

  before do
    Fabricate(:collection_item, collection: collection_one, account: featured_account)
  end

  it 'includes collections and partial accounts with the expected attributes' do
    expect(subject).to include({
      'collections' => [
        a_hash_including({ 'name' => 'Exquisite follows' }),
        a_hash_including({ 'name' => 'Excellent people' }),
      ],
      'partial_accounts' => [
        a_hash_including({ 'id' => collection_owner_one.id.to_s }),
        a_hash_including({ 'id' => collection_owner_two.id.to_s }),
        a_hash_including({ 'id' => featured_account.id.to_s }),
      ],
    })
  end
end
