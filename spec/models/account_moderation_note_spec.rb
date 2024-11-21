# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccountModerationNote do
  describe 'Scopes' do
    describe '.chronological' do
      it 'returns account moderation notes oldest to newest' do
        account = Fabricate(:account)
        note1 = Fabricate(:account_moderation_note, target_account: account)
        note2 = Fabricate(:account_moderation_note, target_account: account)

        expect(account.targeted_moderation_notes.chronological).to eq [note1, note2]
      end
    end
  end

  describe 'Validations' do
    subject { Fabricate.build :account_moderation_note }

    describe 'content' do
      it { is_expected.to_not allow_value('').for(:content) }
      it { is_expected.to validate_length_of(:content).is_at_most(described_class::CONTENT_SIZE_LIMIT) }
    end
  end
end
