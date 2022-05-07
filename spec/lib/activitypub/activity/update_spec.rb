require 'rails_helper'

RSpec.describe ActivityPub::Activity::Update do
  let!(:sender) { Fabricate(:account) }

  before do
    sender.update!(uri: ActivityPub::TagManager.instance.uri_for(sender))
  end

  subject { described_class.new(json, sender) }

  describe '#perform' do
    context 'with an Actor object' do
      let(:modified_sender) do
        sender.tap do |modified_sender|
          modified_sender.display_name = 'Totally modified now'
        end
      end

      let(:actor_json) do
        ActiveModelSerializers::SerializableResource.new(modified_sender, serializer: ActivityPub::ActorSerializer, adapter: ActivityPub::Adapter).as_json
      end

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
        stub_request(:get, actor_json[:followers]).to_return(status: 404)
        stub_request(:get, actor_json[:following]).to_return(status: 404)
        stub_request(:get, actor_json[:featured]).to_return(status: 404)

        subject.perform
      end

      it 'updates profile' do
        expect(sender.reload.display_name).to eq 'Totally modified now'
      end
    end

    context 'with a Question object' do
      let!(:at_time) { Time.now.utc }
      let!(:status) { Fabricate(:status, account: sender, poll: Poll.new(account: sender, options: %w(Bar Baz), cached_tallies: [0, 0], expires_at: at_time + 5.days)) }

      let(:json) do
        {
          '@context': 'https://www.w3.org/ns/activitystreams',
          id: 'foo',
          type: 'Update',
          actor: ActivityPub::TagManager.instance.uri_for(sender),
          object: {
            type: 'Question',
            id: ActivityPub::TagManager.instance.uri_for(status),
            content: 'Foo',
            endTime: (at_time + 5.days).iso8601,
            oneOf: [
              {
                type: 'Note',
                name: 'Bar',
                replies: {
                  type: 'Collection',
                  totalItems: 0,
                },
              },

              {
                type: 'Note',
                name: 'Baz',
                replies: {
                  type: 'Collection',
                  totalItems: 12,
                },
              },
            ],
          },
        }.with_indifferent_access
      end

      before do
        status.update!(uri: ActivityPub::TagManager.instance.uri_for(status))
        subject.perform
      end

      it 'updates poll numbers' do
        expect(status.preloadable_poll.cached_tallies).to eq [0, 12]
      end

      it 'does not set status as edited' do
        expect(status.edited_at).to be_nil
      end
    end
  end
end
