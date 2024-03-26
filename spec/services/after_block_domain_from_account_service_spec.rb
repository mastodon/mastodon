# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AfterBlockDomainFromAccountService do
  subject { described_class.new }

  let(:wolf) { Fabricate(:account, username: 'wolf', domain: 'evil.org', inbox_url: 'https://evil.org/wolf/inbox', protocol: :activitypub) }
  let(:dog)  { Fabricate(:account, username: 'dog', domain: 'evil.org', inbox_url: 'https://evil.org/dog/inbox', protocol: :activitypub) }
  let(:alice) { Fabricate(:account, username: 'alice') }

  before do
    NotificationPermission.create!(account: alice, from_account: wolf)

    wolf.follow!(alice)
    alice.follow!(dog)
  end

  it 'purge followers from blocked domain, remove notification permissions, sends `Reject->Follow`, and records severed relationships', :aggregate_failures do
    expect { subject.call(alice, 'evil.org') }
      .to change { wolf.following?(alice) }.from(true).to(false)
      .and change { NotificationPermission.exists?(account: alice, from_account: wolf) }.from(true).to(false)

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
