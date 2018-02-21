# frozen_string_literal: true

require 'rails_helper'

describe TextBlock, type: :model do
  describe '.silence?' do
    before { Fabricate(:text_block, text: 'silenced', severity: :silence) }

    it 'returns false if the given object does not include silenced texts' do
      attachment = Fabricate(:media_attachment, description: 'fine')
      expect(TextBlock.silence?(attachment)).to eq false
    end

    it 'returns true if description includes silenced texts' do
      attachment = Fabricate(:media_attachment, description: 'silenced')
      expect(TextBlock.silence?(attachment)).to eq true
    end

    it 'returns true if display name includes silenced texts' do
      account = Fabricate(:account, display_name: 'silenced')
      expect(TextBlock.silence?(account)).to eq true
    end

    it 'returns true if name includes silenced texts' do
      tag = Fabricate(:tag, name: 'silenced')
      expect(TextBlock.silence?(tag)).to eq true
    end

    it 'returns true if note includes silenced texts' do
      account = Fabricate(:account, note: 'silenced')
      expect(TextBlock.silence?(account)).to eq true
    end

    it 'returns true if spoiler text includes silenced texts' do
      status = Fabricate(:status, spoiler_text: 'silenced')
      expect(TextBlock.silence?(status)).to eq true
    end

    it 'returns true if text includes silenced texts' do
      status = Fabricate(:status, text: 'silenced')
      expect(TextBlock.silence?(status)).to eq true
    end
  end

  describe '.rejected_texts' do
    it 'includes rejected texts' do
      Fabricate(:text_block, text: 'rejected', severity: :reject)
      expect(TextBlock.rejected_texts).to include 'rejected'
    end

    it 'does not include silenced texts' do
      Fabricate(:text_block, text: 'silenced', severity: :silence)
      expect(TextBlock.rejected_texts).not_to include 'silenced'
    end

    it 'caches' do
      TextBlock.rejected_texts

      expect do |callback|
        ActiveSupport::Notifications.subscribed callback, 'sql.active_record' do
          TextBlock.rejected_texts
        end
      end.not_to yield_control
    end
  end

  describe '.silenced_texts' do
    it 'does not include rejected texts' do
      Fabricate(:text_block, text: 'rejected', severity: :reject)
      expect(TextBlock.silenced_texts).not_to include 'rejected'
    end

    it 'includes silenced texts' do
      Fabricate(:text_block, text: 'silenced', severity: :silence)
      expect(TextBlock.silenced_texts).to include 'silenced'
    end

    it 'caches' do
      TextBlock.silenced_texts

      expect do |callback|
        ActiveSupport::Notifications.subscribed callback, 'sql.active_record' do
          TextBlock.silenced_texts
        end
      end.not_to yield_control
    end
  end

  it 'uncaches rejected texts after commit' do
    TextBlock.rejected_texts

    Fabricate(:text_block)

    expect do |callback|
      ActiveSupport::Notifications.subscribed callback, 'sql.active_record' do
        TextBlock.rejected_texts
      end
    end.to yield_control
  end

  it 'uncaches silenced texts after commit' do
    TextBlock.silenced_texts

    Fabricate(:text_block)

    expect do |callback|
      ActiveSupport::Notifications.subscribed callback, 'sql.active_record' do
        TextBlock.silenced_texts
      end
    end.to yield_control
  end
end
