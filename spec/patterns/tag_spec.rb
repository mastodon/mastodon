# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Tag do
  describe described_class::HASHTAG_RE do
    context 'when string matches' do
      subject { described_class.match(string).to_s }

      context 'with a string including #ａｅｓｔｈｅｔｉｃ' do
        let(:string) { '﻿this is #ａｅｓｔｈｅｔｉｃ' }

        it { is_expected.to eq('#ａｅｓｔｈｅｔｉｃ') }
      end

      context 'with a string including starting digits' do
        let(:string) { 'hello #3d' }

        it { is_expected.to eq('#3d') }
      end

      context 'with a string including middle digits' do
        let(:string) { 'hello #l33ts35k' }

        it { is_expected.to eq('#l33ts35k') }
      end

      context 'with a string including ending digits' do
        let(:string) { 'hello #world2016' }

        it { is_expected.to eq('#world2016') }
      end

      context 'with a string including beginning underscore' do
        let(:string) { 'hello #_test' }

        it { is_expected.to eq('#_test') }
      end

      context 'with a string including middle underscore' do
        let(:string) { 'hello #one_two_three' }

        it { is_expected.to eq('#one_two_three') }
      end

      context 'with a string including ending underscore' do
        let(:string) { 'hello #test_' }

        it { is_expected.to eq('#test_') }
      end

      context 'with a string including middle dots' do
        let(:string) { 'hello #one·two·three' }

        it { is_expected.to eq('#one·two·three') }
      end

      context 'with a string including unicode chars' do
        let(:string) { 'testing #ぼっち・ざ・ろっく' }

        it { is_expected.to eq('#ぼっち・ざ・ろっく') }
      end

      context 'with a ZWNJ string' do
        let(:string) { 'just add #نرم‌افزار and' }

        it { is_expected.to eq('#نرم‌افزار') }
      end

      context 'with a string ending in middle dots' do
        let(:string) { 'hello #one·two·three·' }

        it { is_expected.to eq('#one·two·three') }
      end

      context 'with a string where hashtag follows the letter ß' do
        let(:string) { 'Hello toß #ruby' }

        it { is_expected.to eq('#ruby') }
      end

      context 'with a string with mixed case hashtag' do
        let(:string) { 'Hello #rubyOnRails' }

        it { is_expected.to eq('#rubyOnRails') }
      end
    end

    context 'when string does not match' do
      subject { described_class.match(string) }

      context 'with a string starting with middle dots' do
        let(:string) { 'hello #·one·two·three' }

        it { is_expected.to be_nil }
      end

      context 'with a string of purely-numeric hashtags' do
        let(:string) { 'hello #0123456' }

        it { is_expected.to be_nil }
      end

      context 'with a string of URLs with anchors with non-hashtag characters' do
        let(:string) { 'Check this out https://medium.com/@alice/some-article#.abcdef123' }

        it { is_expected.to be_nil }
      end

      context 'with a string of URLs with hashtag-like anchors' do
        let(:string) { 'https://en.wikipedia.org/wiki/Ghostbusters_(song)#Lawsuit' }

        it { is_expected.to be_nil }
      end

      context 'with a string of URLs with hashtag-like anchors after a numeral' do
        let(:string) { 'https://gcc.gnu.org/bugzilla/show_bug.cgi?id=111895#c4' }

        it { is_expected.to be_nil }
      end

      context 'with a string of URLs with hashtag-like anchors after a non-ascii character' do
        let(:string) { 'https://example.org/testé#foo' }

        it { is_expected.to be_nil }
      end

      context 'with a string of URLs with hashtag-like anchors after an empty query parameter' do
        let(:string) { 'https://en.wikipedia.org/wiki/Ghostbusters_(song)?foo=#Lawsuit' }

        it { is_expected.to be_nil }
      end
    end
  end
end
