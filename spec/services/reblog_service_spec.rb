require 'rails_helper'

RSpec.describe ReblogService do
  let(:alice)  { Fabricate(:account, username: 'alice') }
  let(:bob)    { Fabricate(:account, username: 'bob', domain: 'example.com', salmon_url: 'http://salmon.example.com') }
  let(:status) { Fabricate(:status, account: bob, uri: 'tag:example.com;something:something') }

  subject { ReblogService.new }

  before do
    stub_request(:post, 'http://salmon.example.com')

    subject.(alice, status)
  end

  it 'creates a reblog' do
    expect(status.reblogs.count).to eq 1
  end

  it 'sends a Salmon slap for a remote reblog' do
    expect(a_request(:post, 'http://salmon.example.com')).to have_been_made
  end
end
