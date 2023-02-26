# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::Activity::Block do
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

  context 'when the recipient does not follow the sender' do
    describe '#perform' do
      subject { described_class.new(json, sender) }

      before do
        subject.perform
      end

      it 'creates a block from sender to recipient' do
        expect(sender.blocking?(recipient)).to be true
      end
    end
  end

  context 'when the recipient is already blocked' do
    before do
      sender.block!(recipient, uri: 'old')
    end

    describe '#perform' do
      subject { described_class.new(json, sender) }

      before do
        subject.perform
      end

      it 'creates a block from sender to recipient' do
        expect(sender.blocking?(recipient)).to be true
      end

      it 'sets the uri to that of last received block activity' do
        expect(sender.block_relationships.find_by(target_account: recipient).uri).to eq 'foo'
      end
    end
  end

  context 'when the recipient follows the sender' do
    before do
      recipient.follow!(sender)
    end

    describe '#perform' do
      subject { described_class.new(json, sender) }

      before do
        subject.perform
      end

      it 'creates a block from sender to recipient' do
        expect(sender.blocking?(recipient)).to be true
      end

      it 'ensures recipient is not following sender' do
        expect(recipient.following?(sender)).to be false
      end
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

    describe '#perform' do
      subject { described_class.new(json, sender) }

      before do
        subject.perform
      end

      it 'does not create a block from sender to recipient' do
        expect(sender.blocking?(recipient)).to be false
      end

      it 'ensures recipient is not following sender' do
        expect(recipient.following?(sender)).to be false
      end
    end
  end
end
