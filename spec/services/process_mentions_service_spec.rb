require 'rails_helper'

RSpec.describe ProcessMentionsService do
  let(:account)     { Fabricate(:account, username: 'alice') }
  let(:remote_user) { Fabricate(:account, username: 'remote_user', domain: 'example.com', salmon_url: 'http://salmon.example.com') }
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

  context 'when the status contains a code block' do
    let(:status)      { Fabricate(:status, account: account, text: text) }

    context 'and the code blcok contains a mention' do
      let(:text) { "Hello `@#{remote_user.acct}`" }

      it 'does not create a mention' do
        expect(a_request(:post, remote_user.salmon_url)).not_to have_been_made
        expect(status.reload.mentions).to be_empty
      end
    end
  end
end
