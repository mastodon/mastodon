# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccountModerationNote do
  describe 'chronological scope' do
    it 'returns account moderation notes oldest to newest' do
      account = Fabricate(:account)
      note1 = Fabricate(:account_moderation_note, target_account: account)
      note2 = Fabricate(:account_moderation_note, target_account: account)

      expect(account.targeted_moderation_notes.chronological).to eq [note1, note2]
    end
  end

  describe 'validations' do
    it 'is invalid if the content is empty' do
      report = Fabricate.build(:account_moderation_note, content: '')
      expect(report.valid?).to be false
    end

    it 'is invalid if content is longer than character limit' do
      report = Fabricate.build(:account_moderation_note, content: comment_over_limit)
      expect(report.valid?).to be false
    end

    def comment_over_limit
      Faker::Lorem.paragraph_by_chars(number: described_class::CONTENT_SIZE_LIMIT * 2)
    end
  end
end
