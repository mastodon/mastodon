# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::Activity::Block do
  subject { described_class.new(json, sender) }

  let(:sender)    { Fabricate(:account) }
  let(:recipient) { Fabricate(:account) }

  let(:json) do
    {
      '@context': 'https://www.w3.org/ns/activitystreams',
      id: 'foo',
      type: 'Block',
      actor: ActivityPub::TagManager.instance.uri_for(sender),
      object: ActivityPub::TagManager.instance.uri_for(recipient),
    }.with_indifferent_access
  end

  describe '#perform' do
    context 'when the recipient does not follow the sender' do
      it 'creates a block from sender to recipient' do
        subject.perform

        expect(sender)
          .to be_blocking(recipient)
      end
    end

    context 'when the recipient is already blocked' do
      before { sender.block!(recipient, uri: 'old') }

      it 'creates a block from sender to recipient and sets uri to last received block activity' do
        subject.perform

        expect(sender)
          .to be_blocking(recipient)
        expect(sender.block_relationships.find_by(target_account: recipient).uri)
          .to eq 'foo'
      end
    end

    context 'when the recipient follows the sender' do
      before { recipient.follow!(sender) }

      it 'creates a block from sender to recipient and ensures recipient not following sender' do
        subject.perform

        expect(sender)
          .to be_blocking(recipient)
        expect(recipient)
          .to_not be_following(sender)
      end
    end

    context 'when a matching undo has been received first' do
      let(:undo_json) do
        {
          '@context': 'https://www.w3.org/ns/activitystreams',
          id: 'bar',
          type: 'Undo',
          actor: ActivityPub::TagManager.instance.uri_for(sender),
          object: json,
        }.with_indifferent_access
      end

      before do
        recipient.follow!(sender)
        ActivityPub::Activity::Undo.new(undo_json, sender).perform
      end

      it 'does not create a block from sender to recipient and ensures recipient not following sender' do
        subject.perform

        expect(sender)
          .to_not be_blocking(recipient)
        expect(recipient)
          .to_not be_following(sender)
      end
    end
  end
end
