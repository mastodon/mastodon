require 'rails_helper'

RSpec.describe FavouriteTag, type: :model do
  describe 'initialize' do
    it do
      expect(FavouriteTag.new).not_to be_valid
    end
  end

  describe 'validation' do
    let(:account) { Fabricate :account }
    let(:tag) { Tag.new(name: 'unko unko') }

    it do
      expect(FavouriteTag.new(account: account, tag: tag, visibility: 0)).not_to be_valid
      expect(FavouriteTag.new(account: account, tag: tag, visibility: 1)).not_to be_valid
      expect(FavouriteTag.new(account: account, tag: tag, visibility: 2)).not_to be_valid
      expect(FavouriteTag.new(account: account, tag: tag, visibility: 3)).not_to be_valid
      expect { FavouriteTag.new(account: account, tag: tag, visibility: 4) }.to raise_error(ArgumentError)
    end
  end

  describe 'deletion' do
    let!(:favourite_tag) { Fabricate(:favourite_tag) }

    it do
      expect { favourite_tag.tag.destroy }.to change { FavouriteTag.count }.by(-1)
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
