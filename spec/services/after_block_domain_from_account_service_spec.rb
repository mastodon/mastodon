# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AfterBlockDomainFromAccountService do
  subject { described_class.new }

  let(:wolf) { Fabricate(:account, username: 'wolf', domain: 'evil.org', inbox_url: 'https://evil.org/wolf/inbox', protocol: :activitypub) }
  let(:dog)  { Fabricate(:account, username: 'dog', domain: 'evil.org', inbox_url: 'https://evil.org/dog/inbox', protocol: :activitypub) }
  let(:alice) { Fabricate(:account, username: 'alice') }

  before do
    wolf.follow!(alice)
    alice.follow!(dog)
  end

  around do |example|
    Sidekiq::Testing.fake! do
      example.run
    end
  end

  it 'purges followers from blocked domain, sends them Reject->Follow, and records severed relationships', :aggregate_failures do
    subject.call(alice, 'evil.org')

    expect(wolf.following?(alice)).to be false
    expect(ActivityPub::DeliveryWorker.jobs.pluck('args')).to contain_exactly(
      [a_string_including('"type":"Reject"'), alice.id, wolf.inbox_url],
      [a_string_including('"type":"Undo"'), alice.id, dog.inbox_url]
    )

    severed_relationships = alice.severed_relationships.to_a
    expect(severed_relationships.count).to eq 2
    expect(severed_relationships[0].relationship_severance_event).to eq severed_relationships[1].relationship_severance_event
    expect(severed_relationships.map { |rel| [rel.account, rel.target_account] }).to contain_exactly([wolf, alice], [alice, dog])
  end
end
