# frozen_string_literal: true

require 'rails_helper'

describe ReactionValidator do
  let(:announcement) { Fabricate(:announcement) }

  describe '#validate' do
    it 'adds error when not a valid unicode emoji' do
      reaction = announcement.announcement_reactions.build(name: 'F')
      subject.validate(reaction)
      expect(reaction.errors).to_not be_empty
    end

    it 'does not add error when non-unicode emoji is a custom emoji' do
      custom_emoji = Fabricate(:custom_emoji)
      reaction = announcement.announcement_reactions.build(name: custom_emoji.shortcode, custom_emoji_id: custom_emoji.id)
      subject.validate(reaction)
      expect(reaction.errors).to be_empty
    end

    it 'adds error when reaction limit count has already been reached' do
      stub_const 'ReactionValidator::LIMIT', 2
      %w(🐘 ❤️).each do |name|
        announcement.announcement_reactions.create!(name: name, account: Fabricate(:account))
      end

      reaction = announcement.announcement_reactions.build(name: '😘')
      subject.validate(reaction)
      expect(reaction.errors).to_not be_empty
    end

    it 'does not add error when new reaction is part of the existing ones' do
      %w(🐘 ❤️ 🙉 😍 😋 😂 😞 👍).each do |name|
        announcement.announcement_reactions.create!(name: name, account: Fabricate(:account))
      end

      reaction = announcement.announcement_reactions.build(name: '😋')
      subject.validate(reaction)
      expect(reaction.errors).to be_empty
    end
  end
end
