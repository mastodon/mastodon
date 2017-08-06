require 'rails_helper'

RSpec.describe ActivityPub::Activity::Delete do
  let(:sender)    { Fabricate(:account) }
  let(:status)    { Fabricate(:status, account: sender, uri: 'foobar') }

  let(:json) do
    {
      '@context': 'https://www.w3.org/ns/activitystreams',
      id: 'foo',
      type: 'Delete',
      actor: ActivityPub::TagManager.instance.uri_for(sender),
      object: ActivityPub::TagManager.instance.uri_for(status),
    }.with_indifferent_access
  end

  describe '#perform' do
    subject { described_class.new(json, sender) }

    before do
      subject.perform
    end

    it 'deletes sender\'s status' do
      expect(Status.find_by(id: status.id)).to be_nil
    end
  end
end
