# frozen_string_literal: true

require 'rails_helper'

describe HashtagNormalizer do
  subject { described_class.new }

  describe '#normalize' do
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

    it 'keeps dash(-) character' do
      expect(subject.normalize('a-')).to eq 'a-'
    end
  end
end
