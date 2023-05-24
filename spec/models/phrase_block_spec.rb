# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PhraseBlock do
  describe '#to_regexp' do
    context 'when using a text block' do
      let(:phrase_block) { Fabricate(:phrase_block, phrase: 'evil spam message', filter_type: :text) }

      it 'matches the expected text' do
        expect(phrase_block.to_regexp.match?('this post contains an evil spam message!')).to be true
        expect(phrase_block.to_regexp.match?('this post contains a moderately spammy message!')).to be false
      end
    end
  end
end
