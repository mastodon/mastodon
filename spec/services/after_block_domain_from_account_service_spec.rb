require 'rails_helper'

RSpec.describe AfterBlockDomainFromAccountService, type: :service do
  subject { AfterBlockDomainFromAccountService.new }

  let!(:wolf) { Fabricate(:account, username: 'wolf', domain: 'evil.org', inbox_url: 'https://evil.org/inbox', protocol: :activitypub) }
  let!(:alice) { Fabricate(:account, username: 'alice') }

  before do
    stub_jsonld_contexts!
    allow(ActivityPub::DeliveryWorker).to receive(:perform_async)
  end

  it 'purge followers from blocked domain' do
    wolf.follow!(alice)
    subject.call(alice, 'evil.org')
    expect(wolf.following?(alice)).to be false
  end

  it 'sends Reject->Follow to followers from blocked domain' do
    wolf.follow!(alice)
    subject.call(alice, 'evil.org')
    expect(ActivityPub::DeliveryWorker).to have_received(:perform_async).once
  end
end
