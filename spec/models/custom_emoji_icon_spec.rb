# frozen_string_literal: true

require 'rails_helper'

describe CustomEmojiIcon, type: :model do
  describe 'local scope' do
    it 'returns local custom emoji icons' do
      local = Fabricate(:custom_emoji_icon, uri: nil)
      expect(CustomEmojiIcon.local).to include local
    end

    it 'does not return remote custom emoji icons' do
      remote = Fabricate(:custom_emoji_icon, uri: 'remote')
      expect(CustomEmojiIcon.local).not_to include remote
    end
  end

  describe '#local?' do
    it 'returns true if custom emoji icon is local' do
      local = Fabricate(:custom_emoji_icon, uri: nil)
      expect(local.local?).to eq true
    end

    it 'returns false if custom emoji icon is not local' do
      local = Fabricate(:custom_emoji_icon, uri: 'https://remote/')
      expect(local.local?).to eq false
    end
  end

  describe '#object_type' do
    it 'returns :emoji' do
      expect(Fabricate(:custom_emoji_icon).object_type).to eq :emoji
    end
  end
end
