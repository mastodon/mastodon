# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'spam filter' do # rubocop:disable RSpec/DescribeClass
  subject { ActivityPub::Activity::Create.new(json, sender) }

  let(:sender) { Fabricate(:account, followers_url: 'http://example.com/followers', domain: 'example.com', uri: 'https://example.com/actor') }
  let(:receivers) do
    [
      Fabricate(:account, username: 'receiver_1'),
      Fabricate(:account, username: 'receiver_2'),
    ]
  end

  let(:json) do
    {
      '@context': 'https://www.w3.org/ns/activitystreams',
      id: [ActivityPub::TagManager.instance.uri_for(sender), '#foo'].join,
      type: 'Create',
      actor: ActivityPub::TagManager.instance.uri_for(sender),
      object: {
        id: [ActivityPub::TagManager.instance.uri_for(sender), '#bar'].join,
        type: 'Note',
        published: '2022-01-22T15:00:00Z',
      }.merge(object_json_patch),
    }.with_indifferent_access
  end

  context 'when valid mention sent' do
    let(:object_json_patch) do
      {
        content: '@receiver_1 Lorem ipsum',
        tag: {
          type: 'Mention',
          href: ActivityPub::TagManager.instance.uri_for(receivers.first),
        },
      }
    end

    it 'creates status' do
      subject.perform
      status = Status.find_by!(account_id: sender.id)
      expect(status.content).to eq '@receiver_1 Lorem ipsum'
      expect(status.mentions.size).to eq 1
    end
  end

  context 'when spam mention sent' do
    # remote account, followers = 0, mentions = 2, created_at = Time.now
    let(:object_json_patch) do
      {
        content: '@receiver_1 @receiver_2 Lorem ipsum',
        tag: receivers.map do |receiver|
          {
            type: 'Mention',
            href: ActivityPub::TagManager.instance.uri_for(receiver),
          }
        end,
      }
    end

    it 'does not create status' do
      expect { subject.perform }.to_not change { Status.where(account_id: sender.id).count }.from(0)
    end
  end
end
