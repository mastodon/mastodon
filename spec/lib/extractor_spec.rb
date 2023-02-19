# frozen_string_literal: true

require 'rails_helper'

describe Extractor do
  describe 'extract_mentions_or_lists_with_indices' do
    it 'returns an empty array if the given string does not have at signs' do
      text = 'a string without at signs'
      extracted = Extractor.extract_mentions_or_lists_with_indices(text)
      expect(extracted).to eq []
    end

    it 'does not extract mentions which ends with particular characters' do
      text = '@screen_name@'
      extracted = Extractor.extract_mentions_or_lists_with_indices(text)
      expect(extracted).to eq []
    end

    it 'returns mentions as an array' do
      text = '@screen_name'
      extracted = Extractor.extract_mentions_or_lists_with_indices(text)
      expect(extracted).to eq [
        { screen_name: 'screen_name', indices: [0, 12] },
      ]
    end

    it 'yields mentions if a block is given' do
      text = '@screen_name'
      Extractor.extract_mentions_or_lists_with_indices(text) do |screen_name, start_position, end_position|
        expect(screen_name).to eq 'screen_name'
        expect(start_position).to eq 0
        expect(end_position).to eq 12
      end
    end
  end

  describe 'extract_hashtags_with_indices' do
    it 'returns an empty array if it does not have #' do
      text = 'a string without hash sign'
      extracted = Extractor.extract_hashtags_with_indices(text)
      expect(extracted).to eq []
    end

    it 'does not exclude normal hash text before ://' do
      text = '#hashtag://'
      extracted = Extractor.extract_hashtags_with_indices(text)
      expect(extracted).to eq [{ hashtag: 'hashtag', indices: [0, 8] }]
    end

    it 'excludes http://' do
      text = '#hashtaghttp://'
      extracted = Extractor.extract_hashtags_with_indices(text)
      expect(extracted).to eq [{ hashtag: 'hashtag', indices: [0, 8] }]
    end

    it 'excludes https://' do
      text = '#hashtaghttps://'
      extracted = Extractor.extract_hashtags_with_indices(text)
      expect(extracted).to eq [{ hashtag: 'hashtag', indices: [0, 8] }]
    end

    it 'yields hashtags if a block is given' do
      text = '#hashtag'
      Extractor.extract_hashtags_with_indices(text) do |hashtag, start_position, end_position|
        expect(hashtag).to eq 'hashtag'
        expect(start_position).to eq 0
        expect(end_position).to eq 8
      end
    end
  end

  describe 'extract_cashtags_with_indices' do
    it 'returns []' do
      text = '$cashtag'
      extracted = Extractor.extract_cashtags_with_indices(text)
      expect(extracted).to eq []
    end
  end
end
