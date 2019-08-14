require 'rails_helper'

RSpec.describe ActivityPub::Activity::Follow do
  let(:sender)    { Fabricate(:account) }
  let(:recipient) { Fabricate(:account) }

  let(:json) do
    {
      '@context': 'https://www.w3.org/ns/activitystreams',
      id: 'foo',
      type: 'Follow',
      actor: ActivityPub::TagManager.instance.uri_for(sender),
      object: ActivityPub::TagManager.instance.uri_for(recipient),
    }.with_indifferent_access
  end

  describe '#perform' do
    subject { described_class.new(json, sender) }

    context 'unlocked account' do
      before do
        subject.perform
      end

      it 'creates a follow from sender to recipient' do
        expect(sender.following?(recipient)).to be true
      end

      it 'does not create a follow request' do
        expect(sender.requested?(recipient)).to be false
      end
    end

    context 'silenced account following an unlocked account' do
      before do
        sender.touch(:silenced_at)
        subject.perform
      end

      it 'does not create a follow from sender to recipient' do
        expect(sender.following?(recipient)).to be false
      end

      it 'creates a follow request' do
        expect(sender.requested?(recipient)).to be true
      end
    end

    context 'unlocked account muting the sender' do
      before do
        recipient.mute!(sender)
        subject.perform
      end

      it 'creates a follow from sender to recipient' do
        expect(sender.following?(recipient)).to be true
      end

      it 'does not create a follow request' do
        expect(sender.requested?(recipient)).to be false
      end
    end

    context 'locked account' do
      before do
        recipient.update(locked: true)
        subject.perform
      end

      it 'does not create a follow from sender to recipient' do
        expect(sender.following?(recipient)).to be false
      end

      it 'creates a follow request' do
        expect(sender.requested?(recipient)).to be true
      end
    end

    context 'unlocked account receiving request from blocked account' do
      before do
        allow(ActivityPub::DeliveryWorker).to receive(:perform_async)
        recipient.block!(sender)
        subject.perform
      end

      it 'does not create a follow from sender to recipient' do
        expect(sender.following?(recipient)).to be false
      end

      it 'does not create a follow request' do
        expect(sender.requested?(recipient)).to be false
      end
    end

    context 'unlocked account receiving request from stealthily-blocked account' do
      before do
        allow(ActivityPub::DeliveryWorker).to receive(:perform_async)
        recipient.block!(sender, stealth: true)
        subject.perform
      end

      it 'does not create a follow from sender to recipient' do
        expect(sender.following?(recipient)).to be false
      end

      it 'does not create a follow request' do
        expect(sender.requested?(recipient)).to be false
      end

      it 'does not send a reject' do
        expect(ActivityPub::DeliveryWorker).to_not have_received(:perform_async)
      end
    end
  end
end
