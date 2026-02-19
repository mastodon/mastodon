# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::Forwarder do
  subject { described_class.new(account, payload, status) }

  let(:account) { Fabricate(:account) }
  let(:remote_account) { Fabricate(:account, domain: 'example.com') }
  let(:status) { Fabricate(:status, account: remote_account) }

  let(:signature) { { type: 'RsaSignature2017', signatureValue: 'foo' } }
  let(:payload) do
    {
      '@context': [
        'https://www.w3.org/ns/activitystreams',
        'https://w3id.org/security/v1',
      ],
      signature: signature,
      type: 'Delete',
      object: ActivityPub::TagManager.instance.uri_for(status),
    }.deep_stringify_keys
  end

  describe '#forwardable?' do
    context 'when payload has an inlined signature' do
      it 'returns true' do
        expect(subject.forwardable?).to be true
      end
    end

    context 'when payload has an no inlined signature' do
      let(:signature) { nil }

      it 'returns true' do
        expect(subject.forwardable?).to be false
      end
    end
  end

  describe '#forward!' do
    let(:alice) { Fabricate(:account) }
    let(:bob) { Fabricate(:account) }
    let(:eve) { Fabricate(:account, domain: 'remote1.example.com', inbox_url: 'https://remote1.example.com/users/eve/inbox', protocol: :activitypub) }
    let(:mallory) { Fabricate(:account, domain: 'remote2.example.com', inbox_url: 'https://remote2.example.com/users/mallory/inbox', protocol: :activitypub) }

    before do
      alice.statuses.create!(reblog: status)
      Fabricate(:quote, status: Fabricate(:status, account: bob), quoted_status: status, state: :accepted)

      eve.follow!(alice)
      mallory.follow!(bob)
    end

    it 'correctly forwards to expected remote followers' do
      expect { subject.forward! }
        .to enqueue_sidekiq_job(ActivityPub::LowPriorityDeliveryWorker).with(Oj.dump(payload), anything, eve.preferred_inbox_url)
        .and enqueue_sidekiq_job(ActivityPub::LowPriorityDeliveryWorker).with(Oj.dump(payload), anything, mallory.preferred_inbox_url)
    end
  end
end
