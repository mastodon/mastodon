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

    context 'with no prior follow' do
      context 'unlocked account' do
        before do
          subject.perform
        end

        it 'creates a follow from sender to recipient' do
          expect(sender.following?(recipient)).to be true
          expect(sender.active_relationships.find_by(target_account: recipient).uri).to eq 'foo'
        end

        it 'does not create a follow request' do
          expect(sender.requested?(recipient)).to be false
        end
      end

      context 'with a DomainBlock' do
        let(:blocked) { Fabricate(:account, domain: 'blocked.xyz', protocol: :activitypub, inbox_url: 'http://example.com/inbox') }
        let(:json) do
          {
            '@context': 'https://www.w3.org/ns/activitystreams',
            id: 'baz',
            type: 'Follow',
            actor: ActivityPub::TagManager.instance.uri_for(blocked),
            object: ActivityPub::TagManager.instance.uri_for(recipient),
          }.with_indifferent_access
        end

        subject { described_class.new(json, blocked) }

        before do
          stub_request(:post, 'http://example.com/inbox').to_return(status: 200)
          DomainBlock.create!(domain: blocked.domain, severity: :silence, reject_follows: true)
          subject.perform
        end

        it 'does not create a follow or request' do
          expect(blocked.following?(recipient)).to be false
          expect(blocked.requested?(recipient)).to be false
        end
      end

      context 'with a DomainBlock but previously followed back' do
        let(:blocked) { Fabricate(:account, domain: 'blocked.xyz') }
        let(:json) do
          {
            '@context': 'https://www.w3.org/ns/activitystreams',
            id: 'quux',
            type: 'Follow',
            actor: ActivityPub::TagManager.instance.uri_for(blocked),
            object: ActivityPub::TagManager.instance.uri_for(recipient),
          }.with_indifferent_access
        end

        subject { described_class.new(json, blocked) }

        before do
          recipient.active_relationships.create!(target_account: blocked, uri: 'followback')
          DomainBlock.create!(domain: blocked.domain, severity: :silence, reject_follows: true)
          subject.perform
        end

        it 'creates a follow from sender to recipient' do
          expect(blocked.following?(recipient)).to be true
          expect(blocked.active_relationships.find_by(target_account: recipient).uri).to eq 'quux'
        end

        it 'does not create a follow request' do
          expect(blocked.requested?(recipient)).to be false
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
          expect(sender.follow_requests.find_by(target_account: recipient).uri).to eq 'foo'
        end
      end

      context 'unlocked account muting the sender' do
        before do
          recipient.mute!(sender)
          subject.perform
        end

        it 'creates a follow from sender to recipient' do
          expect(sender.following?(recipient)).to be true
          expect(sender.active_relationships.find_by(target_account: recipient).uri).to eq 'foo'
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
          expect(sender.follow_requests.find_by(target_account: recipient).uri).to eq 'foo'
        end
      end
    end

    context 'when a follow relationship already exists' do
      before do
        sender.active_relationships.create!(target_account: recipient, uri: 'bar')
      end

      context 'unlocked account' do
        before do
          subject.perform
        end

        it 'correctly sets the new URI' do
          expect(sender.active_relationships.find_by(target_account: recipient).uri).to eq 'foo'
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

        it 'correctly sets the new URI' do
          expect(sender.active_relationships.find_by(target_account: recipient).uri).to eq 'foo'
        end

        it 'does not create a follow request' do
          expect(sender.requested?(recipient)).to be false
        end
      end

      context 'unlocked account muting the sender' do
        before do
          recipient.mute!(sender)
          subject.perform
        end

        it 'correctly sets the new URI' do
          expect(sender.active_relationships.find_by(target_account: recipient).uri).to eq 'foo'
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

        it 'correctly sets the new URI' do
          expect(sender.active_relationships.find_by(target_account: recipient).uri).to eq 'foo'
        end

        it 'does not create a follow request' do
          expect(sender.requested?(recipient)).to be false
        end
      end
    end

    context 'when a follow request already exists' do
      before do
        sender.follow_requests.create!(target_account: recipient, uri: 'bar')
      end

      context 'silenced account following an unlocked account' do
        before do
          sender.touch(:silenced_at)
          subject.perform
        end

        it 'does not create a follow from sender to recipient' do
          expect(sender.following?(recipient)).to be false
        end

        it 'correctly sets the new URI' do
          expect(sender.requested?(recipient)).to be true
          expect(sender.follow_requests.find_by(target_account: recipient).uri).to eq 'foo'
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

        it 'correctly sets the new URI' do
          expect(sender.requested?(recipient)).to be true
          expect(sender.follow_requests.find_by(target_account: recipient).uri).to eq 'foo'
        end
      end
    end
  end
end
