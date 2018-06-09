require 'rails_helper'

RSpec.describe BlockDomainFromAccountService, type: :service do
  let!(:wolf) { Fabricate(:account, username: 'wolf', domain: 'evil.org', inbox_url: 'https://evil.org/inbox') }
  let!(:alice) { Fabricate(:account, username: 'alice') }

  subject { BlockDomainFromAccountService.new }

  before do
    stub_jsonld_contexts!
    allow(ActivityPub::DeliveryWorker).to receive(:perform_async)
  end

  it 'creates domain block' do
    subject.call(alice, 'evil.org')
    expect(alice.domain_blocking?('evil.org')).to be true
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
