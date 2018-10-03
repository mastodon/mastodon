require 'rails_helper'

RSpec.describe ConversationAccount, type: :model do
  let!(:alice) { Fabricate(:account, username: 'alice') }
  let!(:bob)   { Fabricate(:account, username: 'bob') }
  let!(:mark)  { Fabricate(:account, username: 'mark') }

  describe '.add_status' do
    it 'creates new record when no others exist' do
      status = Fabricate(:status, account: alice, visibility: :direct)
      status.mentions.create(account: bob)

      conversation = ConversationAccount.add_status(alice, status)

      expect(conversation.participant_accounts).to include(bob)
      expect(conversation.last_status).to eq status
      expect(conversation.status_ids).to be_empty
    end

    it 'appends to old record when there is a match' do
      last_status  = Fabricate(:status, account: alice, visibility: :direct)
      conversation = ConversationAccount.create!(account: alice, conversation: last_status.conversation, participant_account_ids: [bob.id], last_status: last_status)

      status = Fabricate(:status, account: bob, visibility: :direct, thread: last_status)
      status.mentions.create(account: alice)

      new_conversation = ConversationAccount.add_status(alice, status)

      expect(new_conversation.id).to eq conversation.id
      expect(new_conversation.participant_accounts).to include(bob)
      expect(new_conversation.last_status).to eq status
      expect(new_conversation.status_ids).to include(last_status.id)
    end

    it 'creates new record when new participants are added' do
      last_status  = Fabricate(:status, account: alice, visibility: :direct)
      conversation = ConversationAccount.create!(account: alice, conversation: last_status.conversation, participant_account_ids: [bob.id], last_status: last_status)

      status = Fabricate(:status, account: bob, visibility: :direct, thread: last_status)
      status.mentions.create(account: alice)
      status.mentions.create(account: mark)

      new_conversation = ConversationAccount.add_status(alice, status)

      expect(new_conversation.id).to_not eq conversation.id
      expect(new_conversation.participant_accounts).to include(bob, mark)
      expect(new_conversation.last_status).to eq status
      expect(new_conversation.status_ids).to be_empty
    end
  end

  describe '.remove_status' do
    it 'updates last status to a previous value' do
      last_status  = Fabricate(:status, account: alice, visibility: :direct)
      status       = Fabricate(:status, account: alice, visibility: :direct)
      conversation = ConversationAccount.create!(account: alice, conversation: last_status.conversation, participant_account_ids: [bob.id], status_ids: [status.id], last_status: last_status)
      last_status.mentions.create(account: bob)
      last_status.destroy!
      conversation.reload
      expect(conversation.last_status).to eq status
      expect(conversation.status_ids).to be_empty
    end

    it 'removes the record if no other statuses are referenced' do
      last_status  = Fabricate(:status, account: alice, visibility: :direct)
      conversation = ConversationAccount.create!(account: alice, conversation: last_status.conversation, participant_account_ids: [bob.id], last_status: last_status)
      last_status.mentions.create(account: bob)
      last_status.destroy!
      expect(ConversationAccount.where(id: conversation.id).count).to eq 0
    end
  end
end
