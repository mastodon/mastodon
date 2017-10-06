require 'rails_helper'

RSpec.describe Tag, type: :model do
  describe 'validations' do
    it 'invalid with #' do
      expect(Tag.new(name: '#hello_world')).to_not be_valid
    end

    it 'invalid with .' do
      expect(Tag.new(name: '.abcdef123')).to_not be_valid
    end

    it 'invalid with spaces' do
      expect(Tag.new(name: 'hello world')).to_not be_valid
    end

    it 'valid with ａｅｓｔｈｅｔｉｃ' do
      expect(Tag.new(name: 'ａｅｓｔｈｅｔｉｃ')).to be_valid
    end
  end

  describe '.search_for' do
    it 'finds tag records with matching names' do
      tag = Fabricate(:tag, name: "match")
      _miss_tag = Fabricate(:tag, name: "miss")

      results = Tag.search_for("match")

      expect(results).to eq [tag]
    end

    it 'finds tag records in case insensitive' do
      tag = Fabricate(:tag, name: "MATCH")
      _miss_tag = Fabricate(:tag, name: "miss")

      results = Tag.search_for("match")

      expect(results).to eq [tag]
    end

    it 'finds the exact matching tag as the first item' do
      similar_tag = Fabricate(:tag, name: "matchlater")
      tag = Fabricate(:tag, name: "match")

      results = Tag.search_for("match")

      expect(results).to eq [tag, similar_tag]
    end
  end
end
