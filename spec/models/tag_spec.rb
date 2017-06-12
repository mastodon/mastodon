require 'rails_helper'

RSpec.describe Tag, type: :model do
  describe 'HASHTAG_RE' do
    subject { Tag::HASHTAG_RE }

    it 'does not match URLs with anchors with non-hashtag characters' do
      expect(subject.match('Check this out https://medium.com/@alice/some-article#.abcdef123')).to be_nil
    end

    it 'does not match URLs with hashtag-like anchors' do
      expect(subject.match('https://en.wikipedia.org/wiki/Ghostbusters_(song)#Lawsuit')).to be_nil
    end
  end

  describe '.search_for' do
    it 'finds tag records with matching names' do
      tag = Fabricate(:tag, name: "match")
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
