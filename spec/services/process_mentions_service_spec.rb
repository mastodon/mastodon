require 'rails_helper'

RSpec.describe ProcessMentionsService do
  let(:account)     { Fabricate(:account, username: 'alice') }
  let(:remote_user) { Fabricate(:account, username: 'remote_user', domain: 'example.com', salmon_url: 'http://salmon.example.com') }

  context 'when processing a post which is not a reply' do
    let(:status)      { Fabricate(:status, account: account, text: "Hello @#{remote_user.acct}") }

    subject { ProcessMentionsService.new }

    before do
      stub_request(:post, remote_user.salmon_url)
      subject.(status)
    end

    it 'creates a mention' do
      expect(remote_user.mentions.where(status: status).count).to eq 1
    end

    it 'posts to remote user\'s Salmon end point' do
      expect(a_request(:post, remote_user.salmon_url)).to have_been_made
    end
  end

  context 'when processing a reply' do
    let(:asshole)  { Fabricate(:account, username: 'asshole') }
    let(:reply_to) { Fabricate(:status, account: asshole) }
    let(:status)   { Fabricate(:status, account: remote_user, text: "Hello @alice", thread: reply_to) }

    subject { -> { ProcessMentionsService.new.(status) } }

    before do
      Fabricate(:user, account: account)
      account.follow!(remote_user)
    end

    it 'notifies the recipient' do
      is_expected.to change(Notification, :count).by(1)
    end

    it 'does not notify the recipient when it is a reply to a blocked user' do
      account.block!(asshole)
      is_expected.to_not change(Notification, :count)
    end
  end
end
