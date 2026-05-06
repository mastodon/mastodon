# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CollectionsPresenter do
  subject { described_class.new(collections:) }

  let(:collection_owner_one) { Fabricate(:account) }
  let(:collection_owner_two) { Fabricate(:account) }
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

  describe '#accounts' do
    context 'when collections do not have any items' do
      it 'includes only the collection owners' do
        expect(subject.accounts).to contain_exactly(collection_owner_one, collection_owner_two)
      end
    end

    context 'when collections include accounts' do
      let(:accounts) { Fabricate.times(3, :account) }

      before do
        accounts[0..1].each { |a| Fabricate(:collection_item, collection: collection_one, account: a) }
        accounts[1..2].each { |a| Fabricate(:collection_item, collection: collection_two, account: a) }
      end

      it 'includes collection owners and unique preview accounts' do
        expect(subject.accounts).to contain_exactly(
          collection_owner_one,
          collection_owner_two,
          accounts[0],
          accounts[1],
          accounts[2]
        )
      end
    end
  end
end
