require 'rails_helper'

RSpec.describe FavouriteTag, type: :model do
  it { expect(FavouriteTag.new).not_to be_valid }

  describe 'validation' do
    let(:account) { Fabricate :account }
    let(:tag) { Tag.new(name: 'unko unko') }

    it { expect(FavouriteTag.new(account: account, tag: tag)).not_to be_valid }
  end

  describe 'deletion' do
    let!(:favourite_tag) { Fabricate(:favourite_tag) }

    it do
      expect { favourite_tag.tag.destroy }.to change { FavouriteTag.count }.by(-1)
    end
  end
end
