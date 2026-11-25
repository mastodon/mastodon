# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Hashtag do
  subject { described_class }

  describe '.normalize' do
    it 'converts full-width Latin characters into basic Latin characters' do
      expect(subject.normalize('Ｓｙｎｔｈｗａｖｅ')).to eq 'synthwave'
    end

    it 'converts half-width Katakana into Kana characters' do
      expect(subject.normalize('ｼｰｻｲﾄﾞﾗｲﾅｰ')).to eq 'シーサイドライナー'
    end

    it 'converts modified Latin characters into basic Latin characters' do
      expect(subject.normalize('BLÅHAJ')).to eq 'blahaj'
    end

    it 'strips out invalid characters' do
      expect(subject.normalize('#foo')).to eq 'foo'
    end

    it 'keeps valid characters' do
      expect(subject.normalize('a·b')).to eq 'a·b'
    end
  end

  describe 'EXTRACTION_RE' do
    subject { described_class::EXTRACTION_RE }

    it 'does not match URLs with anchors with non-hashtag characters' do
      expect(subject.match('Check this out https://medium.com/@alice/some-article#.abcdef123')).to be_nil
    end

    it 'does not match URLs with hashtag-like anchors' do
      expect(subject.match('https://en.wikipedia.org/wiki/Ghostbusters_(song)#Lawsuit')).to be_nil
    end

    it 'does not match URLs with hashtag-like anchors after a numeral' do
      expect(subject.match('https://gcc.gnu.org/bugzilla/show_bug.cgi?id=111895#c4')).to be_nil
    end

    it 'does not match URLs with hashtag-like anchors after a non-ascii character' do
      expect(subject.match('https://example.org/testé#foo')).to be_nil
    end

    it 'does not match URLs with hashtag-like anchors after an empty query parameter' do
      expect(subject.match('https://en.wikipedia.org/wiki/Ghostbusters_(song)?foo=#Lawsuit')).to be_nil
    end

    it 'does not match URLs with hashtag-like anchors after a dot' do
      expect(subject.match('https://en.wikipedia.org/wiki/Google_LLC_v._Oracle_America,_Inc.#Decision')).to be_nil
    end

    it 'matches a hashtag preceded by a non-break space' do
      expect(subject.match('test #foo').to_s).to eq '#foo'
    end

    it 'matches ﻿#ａｅｓｔｈｅｔｉｃ' do
      expect(subject.match('﻿this is #ａｅｓｔｈｅｔｉｃ').to_s).to eq '#ａｅｓｔｈｅｔｉｃ'
    end

    it 'matches ＃ｆｏｏ' do
      expect(subject.match('this is ＃ｆｏｏ').to_s).to eq '＃ｆｏｏ'
    end

    it 'matches digits at the start' do
      expect(subject.match('hello #3d').to_s).to eq '#3d'
    end

    it 'matches digits in the middle' do
      expect(subject.match('hello #l33ts35k').to_s).to eq '#l33ts35k'
    end

    it 'matches digits at the end' do
      expect(subject.match('hello #world2016').to_s).to eq '#world2016'
    end

    it 'matches underscores at the beginning' do
      expect(subject.match('hello #_test').to_s).to eq '#_test'
    end

    it 'matches underscores at the end' do
      expect(subject.match('hello #test_').to_s).to eq '#test_'
    end

    it 'matches underscores in the middle' do
      expect(subject.match('hello #one_two_three').to_s).to eq '#one_two_three'
    end

    it 'matches middle dots' do
      expect(subject.match('hello #one·two·three').to_s).to eq '#one·two·three'
    end

    it 'matches ・unicode in ぼっち・ざ・ろっく correctly' do
      expect(subject.match('testing #ぼっち・ざ・ろっく').to_s).to eq '#ぼっち・ざ・ろっく'
    end

    it 'matches ZWNJ' do
      expect(subject.match('just add #نرم‌افزار and').to_s).to eq '#نرم‌افزار'
    end

    it 'does not match middle dots at the start' do
      expect(subject.match('hello #·one·two·three')).to be_nil
    end

    it 'does not match middle dots at the end' do
      expect(subject.match('hello #one·two·three·').to_s).to eq '#one·two·three'
    end

    it 'does not match purely-numeric hashtags' do
      expect(subject.match('hello #0123456')).to be_nil
    end

    it 'matches hashtags immediately following the letter ß' do
      expect(subject.match('Hello toß #ruby').to_s).to eq '#ruby'
    end

    it 'matches hashtags containing uppercase characters' do
      expect(subject.match('Hello #rubyOnRails').to_s).to eq '#rubyOnRails'
    end
  end
end
