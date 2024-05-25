# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Conversation do
  describe '#local?' do
    it 'returns true when URI is nil' do
      expect(Fabricate(:conversation).local?).to be true
    end

    it 'returns false when URI is not nil' do
      expect(Fabricate(:conversation, uri: 'abc').local?).to be false
    end
  end
end
