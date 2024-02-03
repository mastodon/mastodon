# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CustomFilterKeyword do
  describe '#to_regex' do
    context 'when whole_word is true' do
      it 'builds a regex with boundaries and the keyword' do
        keyword = described_class.new(whole_word: true, keyword: 'test')

        expect(keyword.to_regex).to eq(/(?mix:\b#{Regexp.escape(keyword.keyword)}\b)/)
      end

      it 'builds a regex with starting boundary and the keyword when end with non-word' do
        keyword = described_class.new(whole_word: true, keyword: 'test#')

        expect(keyword.to_regex).to eq(/(?mix:\btest\#)/)
      end

      it 'builds a regex with end boundary and the keyword when start with non-word' do
        keyword = described_class.new(whole_word: true, keyword: '#test')

        expect(keyword.to_regex).to eq(/(?mix:\#test\b)/)
      end
    end

    context 'when whole_word is false' do
      it 'builds a regex with the keyword' do
        keyword = described_class.new(whole_word: false, keyword: 'test')

        expect(keyword.to_regex).to eq(/test/i)
      end
    end
  end
end
