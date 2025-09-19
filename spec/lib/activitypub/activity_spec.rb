# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::Activity do
  describe 'processing a Create and an Update' do
    let(:sender) { Fabricate(:account, followers_url: 'http://example.com/followers', domain: 'example.com', uri: 'https://example.com/actor') }

    let(:create_json) do
      {
        '@context': [
          'https://www.w3.org/ns/activitystreams',
        ],
        id: [ActivityPub::TagManager.instance.uri_for(sender), '#create'].join,
        type: 'Create',
        actor: ActivityPub::TagManager.instance.uri_for(sender),
        object: {
          id: [ActivityPub::TagManager.instance.uri_for(sender), 'post1'].join('/'),
          type: 'Note',
          to: [
            'https://www.w3.org/ns/activitystreams#Public',
          ],
          content: 'foo',
          published: '2025-05-24T11:03:10Z',
        },
      }.deep_stringify_keys
    end

    let(:update_json) do
      {
        '@context': [
          'https://www.w3.org/ns/activitystreams',
        ],
        id: [ActivityPub::TagManager.instance.uri_for(sender), '#update'].join,
        type: 'Update',
        actor: ActivityPub::TagManager.instance.uri_for(sender),
        object: {
          id: [ActivityPub::TagManager.instance.uri_for(sender), 'post1'].join('/'),
          type: 'Note',
          to: [
            'https://www.w3.org/ns/activitystreams#Public',
          ],
          content: 'bar',
          updated: '2025-05-25T11:03:10Z',
        },
      }.deep_stringify_keys
    end

    before do
      sender.update(uri: ActivityPub::TagManager.instance.uri_for(sender))
    end

    context 'when getting them in order' do
      it 'creates a status with the edited contents' do
        described_class.factory(create_json, sender).perform
        status = described_class.factory(update_json, sender).perform

        expect(status.text).to eq 'bar'
      end
    end

    context 'when getting them out of order' do
      it 'creates a status with the edited contents' do
        described_class.factory(update_json, sender).perform
        status = described_class.factory(create_json, sender).perform

        expect(status.text).to eq 'bar'
      end
    end
  end
end
