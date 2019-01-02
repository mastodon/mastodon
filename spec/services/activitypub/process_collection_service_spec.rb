require 'rails_helper'

RSpec.describe ActivityPub::ProcessCollectionService, type: :service do
  let(:actor) { Fabricate(:account, domain: 'example.com', uri: 'http://example.com/account') }

  let(:payload) do
    {
      '@context': 'https://www.w3.org/ns/activitystreams',
      id: 'foo',
      type: 'Create',
      actor: ActivityPub::TagManager.instance.uri_for(actor),
      object: {
        id: 'bar',
        type: 'Note',
        content: 'Lorem ipsum',
      },
    }
  end

  let(:json) { Oj.dump(payload) }

  subject { described_class.new }

  describe '#call' do
    context 'when actor is the sender'
    context 'when actor differs from sender' do
      let(:forwarder) { Fabricate(:account, domain: 'example.com', uri: 'http://example.com/other_account') }

      it 'does not process payload if no signature exists' do
        expect_any_instance_of(ActivityPub::LinkedDataSignature).to receive(:verify_account!).and_return(nil)
        expect(ActivityPub::Activity).not_to receive(:factory)

        subject.call(json, forwarder)
      end

      it 'processes payload with actor if valid signature exists' do
        payload['signature'] = { 'type' => 'RsaSignature2017' }

        expect_any_instance_of(ActivityPub::LinkedDataSignature).to receive(:verify_account!).and_return(actor)
        expect(ActivityPub::Activity).to receive(:factory).with(instance_of(Hash), actor, instance_of(Hash))

        subject.call(json, forwarder)
      end

      it 'does not process payload if invalid signature exists' do
        payload['signature'] = { 'type' => 'RsaSignature2017' }

        expect_any_instance_of(ActivityPub::LinkedDataSignature).to receive(:verify_account!).and_return(nil)
        expect(ActivityPub::Activity).not_to receive(:factory)

        subject.call(json, forwarder)
      end
    end
  end
end
