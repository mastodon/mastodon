require 'rails_helper'

RSpec.describe FavouriteTag, type: :model do
  describe 'validation' do
    let(:account) { Fabricate :account }
    let(:tag) { Fabricate(:tag, name: "valid_tag") }

    it 'valid visibility' do
      expect(FavouriteTag.new(account: account, tag: tag, visibility: 0)).to be_valid
      expect(FavouriteTag.new(account: account, tag: tag, visibility: 1)).to be_valid
      expect(FavouriteTag.new(account: account, tag: tag, visibility: 2)).to be_valid
      expect(FavouriteTag.new(account: account, tag: tag, visibility: 3)).to be_valid
    end

    context 'when visibility is out of ranges' do
      it 'invalid visibility' do
        expect { FavouriteTag.new(account: account, tag: tag, visibility: 4) }.to raise_error(ArgumentError)
      end
    end

    context 'when the tag is invalid' do
      it 'when tag name is invalid' do
        expect(FavouriteTag.new(account: account, tag: Tag.new(name: 'test tag'), visibility: 0)).not_to be_valid
      end
    end
  end

  describe 'deletion' do
    let!(:favourite_tag) { Fabricate(:favourite_tag) }

    it 'delete favourite_tag' do
      expect { favourite_tag.destroy }.to change { FavouriteTag.count }.by(-1)
      expect { favourite_tag.destroy }.not_to change { FavouriteTag.count }
    end
  end

  describe 'expect to_json_for_api' do
    let(:account) { Fabricate :account }
    let(:tag) { Tag.new(name: 'test_tag') }
    let!(:favourite_tag) { Fabricate(:favourite_tag, account: account, tag: tag) }

    it 'expect to_json_for_api' do
      json = favourite_tag.to_json_for_api
      expect(json[:id]).to eq favourite_tag.id
      expect(json[:name]).to eq 'test_tag'
      expect(json[:visibility]).to eq 'public'
    end
  end
end
