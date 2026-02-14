# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CollectionItem do
  describe 'Validations' do
    subject { Fabricate.build(:collection_item) }

    it { is_expected.to define_enum_for(:state) }

    it { is_expected.to validate_numericality_of(:position).only_integer.is_greater_than(0) }

    context 'when account inclusion is accepted' do
      subject { Fabricate.build(:collection_item, state: :accepted) }

      it { is_expected.to validate_presence_of(:account) }
    end

    context 'when item is local and account is remote' do
      subject { Fabricate.build(:collection_item, account: remote_account) }

      let(:remote_account) { Fabricate.build(:remote_account) }

      it { is_expected.to validate_presence_of(:activity_uri) }
    end

    context 'when item is not local' do
      subject { Fabricate.build(:collection_item, collection: remote_collection) }

      let(:remote_collection) { Fabricate.build(:collection, local: false) }

      it { is_expected.to validate_absence_of(:approval_uri) }

      it { is_expected.to validate_presence_of(:uri) }
    end

    context 'when account is not present' do
      subject { Fabricate.build(:unverified_remote_collection_item) }

      it { is_expected.to validate_presence_of(:object_uri) }
    end
  end

  describe 'Creation' do
    let(:collection) { Fabricate(:collection) }
    let(:other_collection) { Fabricate(:collection) }
    let(:account) { Fabricate(:account) }
    let(:other_account) { Fabricate(:account) }

    it 'automatically sets the `position` if absent' do
      first_item = collection.collection_items.create(account:)
      second_item = collection.collection_items.create(account: other_account)
      unrelated_item = other_collection.collection_items.create(account:)
      custom_item = other_collection.collection_items.create(account: other_account, position: 7)

      expect(first_item.position).to eq 1
      expect(second_item.position).to eq 2
      expect(unrelated_item.position).to eq 1
      expect(custom_item.position).to eq 7
    end
  end
end
