require 'rails_helper'

RSpec.describe ActivityPub::GroupActivity::Update do
  let(:group)  { Fabricate(:group, domain: 'example.com', uri: 'https://example.com/group', display_name: 'Completely original') }
  let(:sender) { group }

  let(:actor_json) do
    {
      '@context': [
        'https://www.w3.org/ns/activitystreams',
      ],
      id: 'https://example.com/group',
      type: 'PublicGroup',
      name: 'Totally modified now',
      inbox: 'https://example.com/g/inbox',
      outbox: 'https://example.com/group/outbox',
      wall: 'https://example.com/group/wall',
      members: 'https://example.com/group/members',
    }
  end

  subject { described_class.new(json, sender) }

  describe '#perform' do
    context 'with an embedded Actor object' do
      let(:json) do
        {
          '@context': 'https://www.w3.org/ns/activitystreams',
          id: 'foo',
          type: 'Update',
          actor: ActivityPub::TagManager.instance.uri_for(sender),
          object: actor_json,
        }.with_indifferent_access
      end

      before do
        stub_request(:get, actor_json[:outbox]).to_return(status: 404)
        stub_request(:get, actor_json[:members]).to_return(status: 404)
        stub_request(:get, actor_json[:wall]).to_return(status: 404)

        subject.perform
      end

      it 'updates profile' do
        expect(sender.reload.display_name).to eq 'Totally modified now'
      end
    end

    context 'with a reference to the Actor object' do
      let(:json) do
        {
          '@context': 'https://www.w3.org/ns/activitystreams',
          id: 'foo',
          type: 'Update',
          actor: ActivityPub::TagManager.instance.uri_for(sender),
          object: ActivityPub::TagManager.instance.uri_for(sender),
        }.with_indifferent_access
      end

      before do
        stub_request(:get, actor_json[:outbox]).to_return(status: 404)
        stub_request(:get, actor_json[:members]).to_return(status: 404)
        stub_request(:get, actor_json[:wall]).to_return(status: 404)
        stub_request(:get, actor_json[:id]).to_return(body: Oj.dump(actor_json), headers: { 'Content-Type' => 'application/activity+json' })

        subject.perform
      end

      it 'updates profile' do
        expect(sender.reload.display_name).to eq 'Totally modified now'
      end
    end

    context 'with an embedded Actor object for a different actor' do
      let(:sender) { Fabricate(:group, domain: 'evil.com', uri: 'https://evil.com/group', display_name: 'Evil group') }

      let(:json) do
        {
          '@context': 'https://www.w3.org/ns/activitystreams',
          id: 'foo',
          type: 'Update',
          actor: ActivityPub::TagManager.instance.uri_for(sender),
          object: actor_json,
        }.with_indifferent_access
      end

      before do
        stub_request(:get, actor_json[:outbox]).to_return(status: 404)
        stub_request(:get, actor_json[:members]).to_return(status: 404)
        stub_request(:get, actor_json[:wall]).to_return(status: 404)

        subject.perform
      end

      it 'does not update either profile' do
        expect(sender.reload.display_name).to eq 'Evil group'
        expect(group.reload.display_name).to eq 'Completely original'
      end
    end
  end
end
