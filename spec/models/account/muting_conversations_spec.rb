# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Account::MutingConversations do
  let(:account) { Fabricate(:account) }
  let(:conversation) { Fabricate(:conversation) }

  describe 'Associations' do
    subject { Fabricate.build :account }

    it { is_expected.to have_many(:conversation_mutes).dependent(:destroy) }
  end

  describe '#mute_conversation!' do
    subject { account.mute_conversation!(conversation) }

    it 'creates and returns ConversationMute' do
      expect { expect(subject).to be_a(ConversationMute) }
        .to change { account.conversation_mutes.count }.by 1
    end
  end

  describe '#unmute_conversation!' do
    subject { account.unmute_conversation!(conversation) }

    context 'when muting the conversation' do
      before { account.conversation_mutes.create(conversation: conversation) }

      it 'returns destroyed ConversationMute' do
        expect(subject)
          .to be_a(ConversationMute)
          .and be_destroyed
      end
    end

    context 'when not muting the conversation' do
      it { is_expected.to be_nil }
    end
  end

  describe '#muting_conversation?' do
    subject { account.muting_conversation?(conversation) }

    context 'when muting the conversation' do
      before { account.conversation_mutes.create(conversation: conversation) }

      it { is_expected.to be(true) }
    end

    context 'when not muting the conversation' do
      it { is_expected.to be(false) }
    end
  end
end
