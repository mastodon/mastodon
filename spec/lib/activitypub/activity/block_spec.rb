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
