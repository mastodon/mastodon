# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CreateCollectionService do
  subject { described_class.new }

  let(:author) { Fabricate.create(:account) }

  describe '#call' do
    let(:base_params) do
      {
        name: 'People to follow',
        description: 'All my favourites',
        sensitive: false,
        discoverable: true,
      }
    end

    context 'when given valid parameters' do
      it 'creates a new local collection' do
        collection = nil

        expect do
          collection = subject.call(base_params, author)
        end.to change(Collection, :count).by(1)

        expect(collection).to be_a(Collection)
        expect(collection).to be_local
      end

      context 'when given account ids' do
        let(:account_ids) do
          Fabricate.times(2, :account).map { |a| a.id.to_s }
        end
        let(:params) do
          base_params.merge(account_ids:)
        end

        it 'also creates collection items' do
          expect do
            subject.call(params, author)
          end.to change(CollectionItem, :count).by(2)
        end
      end

      context 'when given a tag' do
        let(:params) { base_params.merge(tag: '#people') }

        context 'when the tag exists' do
          let!(:tag) { Fabricate.create(:tag, name: 'people') }

          it 'correctly assigns the existing tag' do
            collection = subject.call(params, author)

            expect(collection.tag).to eq tag
          end
        end

        context 'when the tag does not exist' do
          it 'creates a new tag' do
            collection = nil

            expect do
              collection = subject.call(params, author)
            end.to change(Tag, :count).by(1)

            expect(collection.tag.name).to eq 'people'
          end
        end
      end
    end

    context 'when given invalid parameters' do
      it 'raises an exception' do
        expect do
          subject.call({}, author)
        end.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end
end
