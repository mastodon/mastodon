require 'rails_helper'

RSpec.describe ActivityPub::Activity::Accept do
  let(:sender)    { Fabricate(:account) }
  let(:recipient) { Fabricate(:account) }

  let(:json) do
    {
      '@context': 'https://www.w3.org/ns/activitystreams',
      id: 'foo',
      type: 'Accept',
      actor: ActivityPub::TagManager.instance.uri_for(sender),
      object: {
        id: 'bar',
        type: 'Follow',
        actor: ActivityPub::TagManager.instance.uri_for(recipient),
        object: ActivityPub::TagManager.instance.uri_for(sender),
      },
    }.with_indifferent_access
  end

  describe '#perform' do
    subject { described_class.new(json, sender) }

    before do
      allow(RemoteAccountRefreshWorker).to receive(:perform_async)
      Fabricate(:follow_request, account: recipient, target_account: sender)
      subject.perform
    end

    it 'creates a follow relationship' do
      expect(recipient.following?(sender)).to be true
    end

    it 'removes the follow request' do
      expect(recipient.requested?(sender)).to be false
    end

    it 'queues a refresh' do
      expect(RemoteAccountRefreshWorker).to have_received(:perform_async).with(sender.id)
    end
  end

  context 'given a relay' do
    let!(:relay) { Fabricate(:relay, state: :pending, follow_activity_id: 'https://abc-123/456') }

    let(:json) do
      {
        '@context': 'https://www.w3.org/ns/activitystreams',
        id: 'foo',
        type: 'Accept',
        actor: ActivityPub::TagManager.instance.uri_for(sender),
        object: {
          id: 'https://abc-123/456',
          type: 'Follow',
          actor: ActivityPub::TagManager.instance.uri_for(recipient),
          object: ActivityPub::TagManager.instance.uri_for(sender),
        },
      }.with_indifferent_access
    end

    subject { described_class.new(json, sender) }

    it 'marks the relay as accepted' do
      subject.perform
      expect(relay.reload.accepted?).to be true
    end
  end
end
