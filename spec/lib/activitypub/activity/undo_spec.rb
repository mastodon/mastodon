require 'rails_helper'

RSpec.describe ActivityPub::Activity::Undo do
  subject { described_class.new(json, sender) }

  let(:sender) { Fabricate(:account, domain: 'example.com') }

  let(:json) do
    {
      '@context': 'https://www.w3.org/ns/activitystreams',
      id: 'foo',
      type: 'Undo',
      actor: ActivityPub::TagManager.instance.uri_for(sender),
      object: object_json,
    }.with_indifferent_access
  end

  describe '#perform' do
    context 'with Announce' do
      let(:status) { Fabricate(:status) }

      let(:object_json) do
        {
          id: 'bar',
          type: 'Announce',
          actor: ActivityPub::TagManager.instance.uri_for(sender),
          object: ActivityPub::TagManager.instance.uri_for(status),
          atomUri: 'barbar',
        }
      end

      context do
        before do
          Fabricate(:status, reblog: status, account: sender, uri: 'bar')
        end

        it 'deletes the reblog' do
          subject.perform
          expect(sender.reblogged?(status)).to be false
        end
      end

      context 'with atomUri' do
        before do
          Fabricate(:status, reblog: status, account: sender, uri: 'barbar')
        end

        it 'deletes the reblog by atomUri' do
          subject.perform
          expect(sender.reblogged?(status)).to be false
        end
      end

      context 'with only object uri' do
        let(:object_json) { 'bar' }

        before do
          Fabricate(:status, reblog: status, account: sender, uri: 'bar')
        end

        it 'deletes the reblog by uri' do
          subject.perform
          expect(sender.reblogged?(status)).to be false
        end
      end
    end

    context 'with Accept' do
      let(:recipient) { Fabricate(:account) }
      let(:object_json) do
        {
          id: 'bar',
          type: 'Accept',
          actor: ActivityPub::TagManager.instance.uri_for(sender),
          object: 'follow-to-revoke',
        }
      end

      before do
        recipient.follow!(sender, uri: 'follow-to-revoke')
      end

      it 'deletes follow from recipient to sender' do
        subject.perform
        expect(recipient.following?(sender)).to be false
      end

      it 'creates a follow request from recipient to sender' do
        subject.perform
        expect(recipient.requested?(sender)).to be true
      end
    end

    context 'with Block' do
      let(:recipient) { Fabricate(:account) }

      let(:object_json) do
        {
          id: 'bar',
          type: 'Block',
          actor: ActivityPub::TagManager.instance.uri_for(sender),
          object: ActivityPub::TagManager.instance.uri_for(recipient),
        }
      end

      before do
        sender.block!(recipient, uri: 'bar')
      end

      it 'deletes block from sender to recipient' do
        subject.perform
        expect(sender.blocking?(recipient)).to be false
      end

      context 'with only object uri' do
        let(:object_json) { 'bar' }

        it 'deletes block from sender to recipient' do
          subject.perform
          expect(sender.blocking?(recipient)).to be false
        end
      end
    end

    context 'with Follow' do
      let(:recipient) { Fabricate(:account) }

      let(:object_json) do
        {
          id: 'bar',
          type: 'Follow',
          actor: ActivityPub::TagManager.instance.uri_for(sender),
          object: ActivityPub::TagManager.instance.uri_for(recipient),
        }
      end

      before do
        sender.follow!(recipient, uri: 'bar')
      end

      it 'deletes follow from sender to recipient' do
        subject.perform
        expect(sender.following?(recipient)).to be false
      end

      context 'with only object uri' do
        let(:object_json) { 'bar' }

        it 'deletes follow from sender to recipient' do
          subject.perform
          expect(sender.following?(recipient)).to be false
        end
      end
    end

    context 'with Like' do
      let(:status) { Fabricate(:status) }

      let(:object_json) do
        {
          id: 'bar',
          type: 'Like',
          actor: ActivityPub::TagManager.instance.uri_for(sender),
          object: ActivityPub::TagManager.instance.uri_for(status),
        }
      end

      before do
        Fabricate(:favourite, account: sender, status: status)
      end

      it 'deletes favourite from sender to status' do
        subject.perform
        expect(sender.favourited?(status)).to be false
      end
    end
  end
end
