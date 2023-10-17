# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::Activity::Remove do
  let(:sender) { Fabricate(:account, featured_collection_url: 'https://example.com/featured') }
  let(:status) { Fabricate(:status, account: sender) }

  let(:json) do
    {
      '@context': 'https://www.w3.org/ns/activitystreams',
      id: 'foo',
      type: 'Add',
      actor: ActivityPub::TagManager.instance.uri_for(sender),
      object: ActivityPub::TagManager.instance.uri_for(status),
      target: sender.featured_collection_url,
    }.with_indifferent_access
  end

  describe '#perform' do
    subject { described_class.new(json, sender) }

    before do
      StatusPin.create!(account: sender, status: status)
      subject.perform
    end

    it 'removes a pin' do
      expect(sender.pinned?(status)).to be false
    end
  end
end
