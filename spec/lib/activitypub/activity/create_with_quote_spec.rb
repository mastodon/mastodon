# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Create with quoteUrl' do # rubocop:disable RSpec/DescribeClass
  let(:json) do
    {
      '@context': [
        'https://www.w3.org/ns/activitystreams',
        'https://w3id.org/security/v1',
        {
          manuallyApprovesFollowers: 'as:manuallyApprovesFollowers',
          sensitive: 'as:sensitive',
          Hashtag: 'as:Hashtag',
          quoteUrl: 'as:quoteUrl',
          toot: 'http://joinmastodon.org/ns#',
          Emoji: 'toot:Emoji',
          featured: 'toot:featured',
          discoverable: 'toot:discoverable',
          schema: 'http://schema.org#',
          PropertyValue: 'schema:PropertyValue',
          value: 'schema:value',
          vcard: 'http://www.w3.org/2006/vcard/ns#',
        },
      ],
      id: 'https://social.some-quoting-server.com/notes/quoting-status-id/activity',
      actor: 'https://social.some-quoting-server.com/users/quoting-user-id',
      type: 'Create',
      published: '2024-03-31T05:36:53.181Z',
      object: {
        id: 'https://social.some-quoting-server.com/notes/quoting-status-id',
        type: 'Note',
        attributedTo: 'https://social.some-quoting-server.com/users/quoting-user-id',
        content: '<p><span>comment-on-quote<br><br>RE: </span><a href="https://social.some-quoted-server.com/users/quoted-user/statuses/quoted-status-id">https://social.some-quoted-server.com/users/quoted-user/statuses/quoted-status-id</a></p>',
        quoteUrl: 'https://social.some-quoted-server.com/users/quoted-user/statuses/quoted-status-id',
        published: '2024-03-31T05:36:53.181Z',
        to: [
          'https://social.some-quoting-server.com/users/quoting-user-id/followers',
        ],
        cc: [
          'https://www.w3.org/ns/activitystreams#Public',
        ],
        inReplyTo: nil,
        attachment: [],
        sensitive: false,
        tag: [],
      },
      to: [
        'https://social.some-quoting-server.com/users/quoting-user-id/followers',
      ],
      cc: [
        'https://www.w3.org/ns/activitystreams#Public',
      ],
    }.deep_stringify_keys!
  end
  let(:original_status) do
    {
      '@context': [
        'https://www.w3.org/ns/activitystreams',
        {
          ostatus: 'http://ostatus.org#',
          atomUri: 'ostatus:atomUri',
          inReplyToAtomUri: 'ostatus:inReplyToAtomUri',
          conversation: 'ostatus:conversation',
          sensitive: 'as:sensitive',
          toot: 'http://joinmastodon.org/ns#',
          votersCount: 'toot:votersCount',
        },
      ],
      id: 'https://social.some-quoted-server.com/users/quoted-user/statuses/quoted-status-id',
      type: 'Note',
      summary: nil,
      inReplyTo: nil,
      published: '2024-03-29T02:45:41Z',
      url: 'https://social.some-quoted-server.com/@quoted-user/quoted-status-id',
      attributedTo: 'https://social.some-quoted-server.com/users/quoted-user',
      to: [
        'https://social.some-quoted-server.com/users/quoted-user/followers',
      ],
      cc: [
        'https://www.w3.org/ns/activitystreams#Public',
      ],
      sensitive: false,
      atomUri: 'https://social.some-quoted-server.com/users/quoted-user/statuses/quoted-status-id',
      inReplyToAtomUri: nil,
      conversation: 'tag:social.some-quoted-server.com,2024-03-29:objectId=12345:objectType=Conversation',
      content: 'quoted-content',
      contentMap: {
        ja: 'quoted-content',
      },
      attachment: [],
      tag: [],
      replies: {
        id: 'https://social.some-quoted-server.com/users/quoted-user/statuses/quoted-status-id/replies',
        type: 'Collection',
        first: {
          type: 'CollectionPage',
          next: 'https://social.some-quoted-server.com/users/quoted-user/statuses/quoted-status-id/replies?only_other_accounts=true&page=true',
          partOf: 'https://social.some-quoted-server.com/users/quoted-user/statuses/quoted-status-id/replies',
          items: [],
        },
      },
    }.deep_stringify_keys!
  end

  def stub_fetch_remote_account_service(url:, username:, domain:)
    stub_request(:get, url).to_return(
      body: Oj.dump(
        {
          '@context': 'https://www.w3.org/ns/activitystreams',
          id: url,
          type: 'Person',
          preferredUsername: username.to_s,
          name: username,
          summary: 'Foo bar',
          inbox: "#{url}/inbox",
        }
      ),
      headers: { 'Content-Type': 'application/activity+json' }
    )
    stub_request(:get, "https://#{domain}/.well-known/webfinger?resource=acct:#{username}@#{domain}").to_return(
      body: Oj.dump({ subject: "acct:#{username}@#{domain}", links: [{ rel: 'self', href: url, type: 'application/activity+json' }] }),
      headers: { 'Content-Type': 'application/jrd+json' }
    )
  end

  before do
    stub_request(:get, 'https://social.some-quoted-server.com/users/quoted-user/statuses/quoted-status-id').to_return(body: JSON.dump(original_status))
    stub_request(:get, 'https://social.some-quoted-server.com/users/quoted-user/statuses/quoted-status-id').to_return(body: JSON.dump(original_status))
    stub_fetch_remote_account_service(url: 'https://social.some-quoted-server.com/users/quoted-user', username: 'quoted-user', domain: 'social.some-quoted-server.com')
  end

  describe 'smoke test' do
    subject { ActivityPub::Activity::Create.new(json, quoting_account) }

    let(:quoting_account) { Fabricate(:account, domain: 'social.some-quoting-server.com', username: 'quoting-user-id') }

    around do |example|
      Sidekiq::Testing.fake! do
        example.run
        Sidekiq::Worker.clear_all
      end
    end

    def fetch_quoted_account
      Account.find_by(username: 'quoted-user', domain: 'social.some-quoted-server.com')
    end

    it 'creates quoted(original) status\' owner account' do
      expect { subject.perform }.to change {
        fetch_quoted_account&.acct
      }.from(nil).to('quoted-user@social.some-quoted-server.com')
    end

    it 'creates quoted(original) status' do
      subject.perform

      expect(fetch_quoted_account.statuses.first.text).to match(/quoted-content/)
    end

    it 'creates quoting status with url in text replaced' do
      subject.perform

      quoting_status_text = quoting_account.statuses.first.text
      expect(quoting_status_text).to match(/comment-on-quote/)
      # cb6e6126.ngrok.io is LOCAL_DOMAIN on test environment
      rewrote_link = "https://cb6e6126.ngrok.io/@quoted-user@social.some-quoted-server.com/#{fetch_quoted_account.statuses.first.id}"
      original_link = 'https://social.some-quoted-server.com/users/quoted-user/statuses/quoted-status-id'
      expect(quoting_status_text).to match %r{<a href="#{rewrote_link}">#{original_link}</a>}
    end
  end
end
