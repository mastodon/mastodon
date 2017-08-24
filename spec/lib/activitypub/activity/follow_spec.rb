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
  end
end
