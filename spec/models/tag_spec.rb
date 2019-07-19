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

  describe 'HASHTAG_RE' do
    subject { Tag::HASHTAG_RE }

    it 'does not match URLs with anchors with non-hashtag characters' do
      expect(subject.match('Check this out https://medium.com/@alice/some-article#.abcdef123')).to be_nil
    end

    it 'does not match URLs with hashtag-like anchors' do
      expect(subject.match('https://en.wikipedia.org/wiki/Ghostbusters_(song)#Lawsuit')).to be_nil
    end

    it 'matches ﻿#ａｅｓｔｈｅｔｉｃ' do
      expect(subject.match('﻿this is #ａｅｓｔｈｅｔｉｃ').to_s).to eq ' #ａｅｓｔｈｅｔｉｃ'
    end

    it 'matches digits at the start' do
      expect(subject.match('hello #3d').to_s).to eq ' #3d'
    end

    it 'matches digits in the middle' do
      expect(subject.match('hello #l33ts35k').to_s).to eq ' #l33ts35k'
    end

    it 'matches digits at the end' do
      expect(subject.match('hello #world2016').to_s).to eq ' #world2016'
    end

    it 'matches underscores at the beginning' do
      expect(subject.match('hello #_test').to_s).to eq ' #_test'
    end

    it 'matches underscores at the end' do
      expect(subject.match('hello #test_').to_s).to eq ' #test_'
    end

    it 'matches underscores in the middle' do
      expect(subject.match('hello #one_two_three').to_s).to eq ' #one_two_three'
    end

    it 'matches middle dots' do
      expect(subject.match('hello #one·two·three').to_s).to eq ' #one·two·three'
    end

    it 'does not match middle dots at the start' do
      expect(subject.match('hello #·one·two·three')).to be_nil
    end

    it 'does not match middle dots at the end' do
      expect(subject.match('hello #one·two·three·').to_s).to eq ' #one·two·three'
    end

    it 'does not match purely-numeric hashtags' do
      expect(subject.match('hello #0123456')).to be_nil
    end
  end

  describe '#to_param' do
    it 'returns name' do
      tag = Fabricate(:tag, name: 'foo')
      expect(tag.to_param).to eq 'foo'
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
