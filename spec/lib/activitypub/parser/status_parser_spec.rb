# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::Parser::StatusParser do
  subject { described_class.new(json) }

  let(:sender) { Fabricate(:account, followers_url: 'http://example.com/followers', domain: 'example.com', uri: 'https://example.com/actor') }
  let(:follower) { Fabricate(:account, username: 'bob') }

  let(:json) do
    {
      '@context': 'https://www.w3.org/ns/activitystreams',
      id: [ActivityPub::TagManager.instance.uri_for(sender), '#foo'].join,
      type: 'Create',
      actor: ActivityPub::TagManager.instance.uri_for(sender),
      object: object_json,
    }.with_indifferent_access
  end

  let(:object_json) do
    {
      id: [ActivityPub::TagManager.instance.uri_for(sender), 'post1'].join('/'),
      type: 'Note',
      to: [
        'https://www.w3.org/ns/activitystreams#Public',
        ActivityPub::TagManager.instance.uri_for(follower),
      ],
      content: '@bob lorem ipsum',
      contentMap: {
        EN: '@bob lorem ipsum',
      },
      published: 1.hour.ago.utc.iso8601,
      updated: 1.hour.ago.utc.iso8601,
      tag: {
        type: 'Mention',
        href: ActivityPub::TagManager.instance.uri_for(follower),
      },
    }
  end

  it 'correctly parses status' do
    expect(subject).to have_attributes(
      text: '@bob lorem ipsum',
      uri: [ActivityPub::TagManager.instance.uri_for(sender), 'post1'].join('/'),
      reply: false,
      language: :en
    )
  end
end
