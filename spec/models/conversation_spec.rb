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

  describe '#to_message_id' do
    it 'converts the conversation details into a string ID' do
      conversation = described_class.new(id: 123, created_at: DateTime.new(2024, 1, 1))

      expect(conversation.to_message_id)
        .to eq('conversation-123.2024-01-01')
    end
  end
end
