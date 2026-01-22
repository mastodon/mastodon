# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Collection do
  describe 'Validations' do
    subject { Fabricate.build :collection }

    it { is_expected.to validate_presence_of(:name) }

    it { is_expected.to validate_presence_of(:description) }

    it { is_expected.to_not allow_value(nil).for(:local) }

    it { is_expected.to_not allow_value(nil).for(:sensitive) }

    it { is_expected.to_not allow_value(nil).for(:discoverable) }

    it { is_expected.to allow_value('en').for(:language) }

    it { is_expected.to_not allow_value('randomstuff').for(:language) }

    context 'when collection is remote' do
      subject { Fabricate.build :collection, local: false }

      it { is_expected.to validate_presence_of(:uri) }

      it { is_expected.to validate_presence_of(:original_number_of_items) }

      it { is_expected.to allow_value('randomstuff').for(:language) }
    end

    context 'when using a hashtag as category' do
      subject { Fabricate.build(:collection, tag:) }

      context 'when hashtag is usable' do
        let(:tag) { Fabricate.build(:tag) }

        it { is_expected.to be_valid }
      end

      context 'when hashtag is not usable' do
        let(:tag) { Fabricate.build(:tag, usable: false) }

        it { is_expected.to_not be_valid }
      end
    end

    context 'when there are more items than allowed' do
      subject { Fabricate.build(:collection, collection_items:) }

      let(:collection_items) { Fabricate.build_times(described_class::MAX_ITEMS + 1, :collection_item, collection: nil) }

      it { is_expected.to_not be_valid }
    end
  end

  describe '#item_for' do
    subject { Fabricate(:collection) }

    let!(:items) { Fabricate.times(2, :collection_item, collection: subject) }

    context 'when given no account' do
      it 'returns all items' do
        expect(subject.items_for).to match_array(items)
      end
    end

    context 'when given an account' do
      let(:account) { Fabricate(:account) }

      before do
        account.block!(items.first.account)
      end

      it 'does not return items blocked by this account' do
        expect(subject.items_for(account)).to contain_exactly(items.last)
      end
    end
  end

  describe '#tag_name=' do
    context 'when the collection is new and has no tag' do
      subject { Fabricate.build(:collection) }

      context 'when the tag exists' do
        let!(:tag) { Fabricate.create(:tag, name: 'people') }

        it 'correctly assigns the existing tag' do
          subject.tag_name = '#people'

          expect(subject.tag).to eq tag
        end
      end

      context 'when the tag does not exist' do
        it 'creates and assigns a new tag' do
          expect do
            subject.tag_name = '#people'
          end.to change(Tag, :count).by(1)

          expect(subject.tag).to be_present
          expect(subject.tag.name).to eq 'people'
        end
      end
    end

    context 'when the collection is persisted and has a tag' do
      subject { Fabricate(:collection, tag:) }

      let!(:tag) { Fabricate(:tag, name: 'people') }

      context 'when the new tag is the same' do
        it 'does not change the object' do
          subject.tag_name = '#People'

          expect(subject.tag).to eq tag
          expect(subject).to_not be_changed
        end
      end

      context 'when the new tag is different' do
        it 'creates and assigns a new tag' do
          expect do
            subject.tag_name = '#bots'
          end.to change(Tag, :count).by(1)

          expect(subject.tag).to be_present
          expect(subject.tag.name).to eq 'bots'
          expect(subject).to be_changed
        end
      end
    end
  end

  describe '#object_type' do
    it 'returns `:featured_collection`' do
      expect(subject.object_type).to eq :featured_collection
    end
  end
end
