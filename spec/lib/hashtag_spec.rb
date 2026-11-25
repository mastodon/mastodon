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
    subject { described_class::EXTRACTION_RE.match(text)&.to_s }

    context 'with URL anchors containing non-hashtag characters' do
      let(:text) { 'Check this out https://medium.com/@alice/some-article#.abcdef123' }

      it { is_expected.to be_nil }
    end

    context 'with hashtag-like URL anchors' do
      let(:text) { 'https://en.wikipedia.org/wiki/Ghostbusters_(song)#Lawsuit' }

      it { is_expected.to be_nil }
    end

    context 'with hashtag-like URL anchors after a numeral' do
      let(:text) { 'https://gcc.gnu.org/bugzilla/show_bug.cgi?id=111895#c4' }

      it { is_expected.to be_nil }
    end

    context 'with hashtag-like URL anchors after a non-ASCII character' do
      let(:text) { 'https://example.org/testé#foo' }

      it { is_expected.to be_nil }
    end

    context 'with hashtag-like URL anchors after an empty query parameter' do
      let(:text) { 'https://en.wikipedia.org/wiki/Ghostbusters_(song)?foo=#Lawsuit' }

      it { is_expected.to be_nil }
    end

    context 'with hashtag-like URL anchors after a dot' do
      let(:text) { 'https://en.wikipedia.org/wiki/Google_LLC_v._Oracle_America,_Inc.#Decision' }

      it { is_expected.to be_nil }
    end

    context 'with a hashtag preceded by a non-break space' do
      let(:text) { 'test #foo' }

      it { is_expected.to eq '#foo' }
    end

    context 'with full-width Latin characters' do
      let(:text) { '﻿this is #ａｅｓｔｈｅｔｉｃ' }

      it { is_expected.to eq '#ａｅｓｔｈｅｔｉｃ' }
    end

    context 'with a full-width hash symbol' do
      let(:text) { 'this is ＃ｆｏｏ' }

      it { is_expected.to eq '＃ｆｏｏ' }
    end

    context 'with digits at the start' do
      let(:text) { 'hello #3d' }

      it { is_expected.to eq '#3d' }
    end

    context 'with digits in the middle' do
      let(:text) { 'hello #l33ts35k' }

      it { is_expected.to eq '#l33ts35k' }
    end

    context 'with digits at the end' do
      let(:text) { 'hello #world2016' }

      it { is_expected.to eq '#world2016' }
    end

    context 'with underscores at the beginning' do
      let(:text) { 'hello #_test' }

      it { is_expected.to eq '#_test' }
    end

    context 'with underscores at the end' do
      let(:text) { 'hello #test_' }

      it { is_expected.to eq '#test_' }
    end

    context 'with underscores in the middle' do
      let(:text) { 'hello #one_two_three' }

      it { is_expected.to eq '#one_two_three' }
    end

    context 'with middle dots' do
      let(:text) { 'hello #one·two·three' }

      it { is_expected.to eq '#one·two·three' }
    end

    context 'with Katakana middle dots' do
      let(:text) { 'testing #ぼっち・ざ・ろっく' }

      it { is_expected.to eq '#ぼっち・ざ・ろっく' }
    end

    context 'with a zero-width non-joiner' do
      let(:text) { 'just add #نرم‌افزار and' }

      it { is_expected.to eq '#نرم‌افزار' }
    end

    context 'with middle dots at the start' do
      let(:text) { 'hello #·one·two·three' }

      it { is_expected.to be_nil }
    end

    context 'with middle dots at the end' do
      let(:text) { 'hello #one·two·three·' }

      it { is_expected.to eq '#one·two·three' }
    end

    context 'with purely numeric hashtags' do
      let(:text) { 'hello #0123456' }

      it { is_expected.to be_nil }
    end

    context 'with a hashtag following the letter ß and a space' do
      let(:text) { 'Hello toß #ruby' }

      it { is_expected.to eq '#ruby' }
    end

    context 'with uppercase characters' do
      let(:text) { 'Hello #rubyOnRails' }

      it { is_expected.to eq '#rubyOnRails' }
    end
  end
end
