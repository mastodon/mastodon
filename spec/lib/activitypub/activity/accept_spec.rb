require 'rails_helper'

RSpec.describe ActivityPub::Activity::Accept do
  let(:sender)    { Fabricate(:account) }
  let(:recipient) { Fabricate(:account) }
  let!(:follow_request) { Fabricate(:follow_request, account: recipient, target_account: sender) }

  describe '#perform' do
    subject { described_class.new(json, sender) }

    before do
      subject.perform
    end

    context 'with concerete object representation' do
      let(:json) do
        {
          '@context': 'https://www.w3.org/ns/activitystreams',
          id: 'foo',
          type: 'Accept',
          actor: ActivityPub::TagManager.instance.uri_for(sender),
          object: {
            type: 'Follow',
            actor: ActivityPub::TagManager.instance.uri_for(recipient),
            object: ActivityPub::TagManager.instance.uri_for(sender),
          },
        }.with_indifferent_access
      end

      it 'creates a follow relationship' do
        expect(recipient.following?(sender)).to be true
      end
    end

    context 'with object represented by id' do
      let(:json) do
        {
          '@context': 'https://www.w3.org/ns/activitystreams',
          id: 'foo',
          type: 'Accept',
          actor: ActivityPub::TagManager.instance.uri_for(sender),
          object: ActivityPub::TagManager.instance.uri_for(follow_request),
        }.with_indifferent_access
      end

      it 'creates a follow relationship' do
        expect(recipient.following?(sender)).to be true
      end
    end
  end
end
