# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::ProcessAccountService do
  subject { described_class.new }

  context 'with property values, an avatar, and a profile header' do
    let(:payload) do
      {
        id: 'https://foo.test',
        type: 'Actor',
        inbox: 'https://foo.test/inbox',
        attachment: [
          { type: 'PropertyValue', name: 'Pronouns', value: 'They/them' },
          { type: 'PropertyValue', name: 'Occupation', value: 'Unit test' },
          { type: 'PropertyValue', name: 'non-string', value: %w(foo bar) },
        ],
        image: {
          type: 'Image',
          mediaType: 'image/png',
          url: 'https://foo.test/image.png',
        },
        icon: {
          type: 'Image',
          url: [
            {
              mediaType: 'image/png',
              href: 'https://foo.test/icon.png',
            },
          ],
        },
      }.with_indifferent_access
    end

    before do
      stub_request(:get, 'https://foo.test/image.png').to_return(request_fixture('avatar.txt'))
      stub_request(:get, 'https://foo.test/icon.png').to_return(request_fixture('avatar.txt'))
    end

    it 'parses property values, avatar and profile header as expected' do
      account = subject.call('alice', 'example.com', payload)

      expect(account.fields)
        .to be_an(Array)
        .and have_attributes(size: 2)
      expect(account.fields.first)
        .to be_an(Account::Field)
        .and have_attributes(
          name: eq('Pronouns'),
          value: eq('They/them')
        )
      expect(account.fields.last)
        .to be_an(Account::Field)
        .and have_attributes(
          name: eq('Occupation'),
          value: eq('Unit test')
        )
      expect(account).to have_attributes(
        avatar_remote_url: 'https://foo.test/icon.png',
        header_remote_url: 'https://foo.test/image.png'
      )
    end
  end

  context 'with collection URIs', feature: :collections do
    let(:payload) do
      {
        'id' => 'https://foo.test',
        'type' => 'Actor',
        'inbox' => 'https://foo.test/inbox',
        'featured' => 'https://foo.test/featured',
        'followers' => 'https://foo.test/followers',
        'following' => 'https://foo.test/following',
        'featuredCollections' => 'https://foo.test/featured_collections',
      }
    end

    before do
      stub_request(:get, %r{^https://foo\.test/follow})
        .to_return(status: 200, body: '', headers: {})
    end

    it 'parses and sets the URIs, queues jobs to synchronize' do
      account = subject.call('alice', 'example.com', payload)

      expect(account.featured_collection_url).to eq 'https://foo.test/featured'
      expect(account.followers_url).to eq 'https://foo.test/followers'
      expect(account.following_url).to eq 'https://foo.test/following'
      expect(account.collections_url).to eq 'https://foo.test/featured_collections'

      expect(ActivityPub::SynchronizeFeaturedCollectionWorker).to have_enqueued_sidekiq_job
      expect(ActivityPub::SynchronizeFeaturedCollectionsCollectionWorker).to have_enqueued_sidekiq_job
    end
  end

  context 'with a single keypair' do
    let(:public_key) { 'foo' }

    let(:payload) do
      {
        id: 'https://foo.test/actor',
        type: 'Actor',
        inbox: 'https://foo.test/inbox',
        preferredUsername: 'alice',
        publicKey: {
          id: 'https://foo.test/actor#key1',
          owner: 'https://foo.test/actor',
          publicKeyPem: public_key,
        },
      }.with_indifferent_access
    end

    it 'stores the key' do
      account = subject.call('alice', 'example.com', payload)

      expect(account.public_key).to eq ''
      expect(account.keypairs).to contain_exactly(
        have_attributes(
          uri: 'https://foo.test/actor#key1',
          type: 'rsa',
          public_key:
        )
      )
    end

    context 'when the account was known with a legacy key' do
      let!(:alice) { Fabricate(:account, uri: 'https://foo.test/actor', domain: 'example.com', username: 'alice') }

      it 'invalidates the legacy key and stores the new key' do
        expect { subject.call('alice', 'example.com', payload) }
          .to change { alice.reload.public_key }.to('')
          .and change { alice.reload.keypairs.to_a }.from([]).to(contain_exactly(have_attributes({ uri: 'https://foo.test/actor#key1', type: 'rsa', public_key: })))
      end
    end

    context 'when the account was known with an old key' do
      let!(:alice) { Fabricate(:account, uri: 'https://foo.test/actor', domain: 'example.com', username: 'alice', public_key: '') }

      before do
        Fabricate(:keypair, account: alice, uri: 'https://foo.test/actor#old-key', type: :rsa)
      end

      it 'invalidates the legacy key and stores the new key' do
        expect { subject.call('alice', 'example.com', payload) }
          .to change { alice.reload.keypairs.to_a }.from(contain_exactly(have_attributes({ uri: 'https://foo.test/actor#old-key' }))).to(contain_exactly(have_attributes({ uri: 'https://foo.test/actor#key1', type: 'rsa', public_key: })))

        expect(alice.reload.public_key)
          .to eq ''
      end
    end
  end

  context 'when the key is in a separate document' do
    let(:key_id) { 'https://foo.test/actor/main-key' }
    let(:public_key) { 'foo' }

    let(:payload) do
      {
        id: 'https://foo.test/actor',
        type: 'Actor',
        inbox: 'https://foo.test/inbox',
        preferredUsername: 'alice',
        publicKey: key_id,
      }.deep_stringify_keys
    end

    let(:key_document) do
      {
        id: key_id,
        owner: 'https://foo.test/actor',
        publicKeyPem: public_key,
      }.deep_stringify_keys
    end

    before do
      stub_request(:get, key_id).to_return(status: 200, body: key_document.to_json, headers: { 'Content-Type': 'application/activity+json' })
    end

    it 'stores the key' do
      account = subject.call('alice', 'example.com', payload)

      expect(account.public_key).to eq ''
      expect(account.keypairs).to contain_exactly(
        have_attributes(
          uri: key_id,
          public_key:,
          type: 'rsa'
        )
      )
    end

    context 'when the key document is a bogus copy of the author (GoToSocial quirk)' do
      let(:payload) do
        {
          id: 'https://foo.test/actor',
          type: 'Actor',
          inbox: 'https://foo.test/inbox',
          preferredUsername: 'alice',
          publicKey: {
            id: key_id,
            owner: 'https://foo.test/actor',
            publicKeyPem: public_key,
          },
        }.deep_stringify_keys
      end

      let(:key_document) { payload }

      it 'stores the key' do
        account = subject.call('alice', 'example.com', payload)

        expect(account.public_key).to eq ''
        expect(account.keypairs).to contain_exactly(
          have_attributes(
            uri: key_id,
            public_key:,
            type: 'rsa'
          )
        )
      end
    end

    context 'when the account was known with a legacy key' do
      let!(:alice) { Fabricate(:account, uri: 'https://foo.test/actor', domain: 'example.com', username: 'alice') }

      it 'invalidates the legacy key and stores the new key' do
        expect { subject.call('alice', 'example.com', payload) }
          .to change { alice.reload.public_key }.to('')
          .and change { alice.reload.keypairs.to_a }.from([]).to(contain_exactly(have_attributes({ uri: key_id, type: 'rsa', public_key: })))
      end
    end

    context 'when the account was known with an old key' do
      let!(:alice) { Fabricate(:account, uri: 'https://foo.test/actor', domain: 'example.com', username: 'alice', public_key: '') }

      before do
        Fabricate(:keypair, account: alice, uri: 'https://foo.test/actor#old-key', type: :rsa)
      end

      it 'invalidates the legacy key and stores the new key' do
        expect { subject.call('alice', 'example.com', payload) }
          .to change { alice.reload.keypairs.to_a }.from(contain_exactly(have_attributes({ uri: 'https://foo.test/actor#old-key' }))).to(contain_exactly(have_attributes({ uri: key_id, type: 'rsa', public_key: })))

        expect(alice.reload.public_key)
          .to eq ''
      end
    end
  end

  context 'with multiple keypairs' do
    let(:payload) do
      {
        id: 'https://foo.test/actor',
        type: 'Actor',
        inbox: 'https://foo.test/inbox',
        preferredUsername: 'alice',
        publicKey: [
          {
            id: 'https://foo.test/actor#key1',
            owner: 'https://foo.test/actor',
            publicKeyPem: 'foo',
          },
          {
            id: 'https://foo.test/actor#key2',
            owner: 'https://foo.test/actor',
            publicKeyPem: 'bar',
          },
        ],
      }.with_indifferent_access
    end

    it 'stores the keys' do
      account = subject.call('alice', 'example.com', payload)

      expect(account.public_key).to eq ''
      expect(account.keypairs).to contain_exactly(
        have_attributes(
          uri: 'https://foo.test/actor#key1',
          type: 'rsa',
          public_key: 'foo'
        ),
        have_attributes(
          uri: 'https://foo.test/actor#key2',
          type: 'rsa',
          public_key: 'bar'
        )
      )
    end

    context 'when the account was known with a legacy key' do
      let!(:alice) { Fabricate(:account, uri: 'https://foo.test/actor', domain: 'example.com', username: 'alice') }

      it 'invalidates the legacy key and stores the new keys' do
        expect { subject.call('alice', 'example.com', payload) }
          .to change { alice.reload.public_key }.to('')
          .and change { alice.keypairs.to_a }.from([]).to(
            contain_exactly(
              have_attributes({ uri: 'https://foo.test/actor#key1', type: 'rsa', public_key: 'foo' }),
              have_attributes({ uri: 'https://foo.test/actor#key2', type: 'rsa', public_key: 'bar' })
            )
          )
      end
    end
  end

  context 'with attribution domains' do
    let(:payload) do
      {
        id: 'https://foo.test',
        type: 'Actor',
        inbox: 'https://foo.test/inbox',
        attributionDomains: [
          'example.com',
        ],
      }.with_indifferent_access
    end

    it 'parses attribution domains' do
      account = subject.call('alice', 'example.com', payload)

      expect(account.attribution_domains)
        .to match_array(%w(example.com))
    end
  end

  context 'with profile settings' do
    let(:payload) do
      {
        id: 'https://foo.test',
        type: 'Actor',
        inbox: 'https://foo.test/inbox',
        showMedia: true,
        showRepliesInMedia: false,
        showFeatured: false,
      }.with_indifferent_access
    end

    it 'sets the profile settings as expected' do
      account = subject.call('alice', 'example.com', payload)

      expect(account)
        .to have_attributes(
          show_media: true,
          show_media_replies: false,
          show_featured: false
        )
    end
  end

  context 'with inlined feature collection' do
    let(:payload) do
      {
        id: 'https://foo.test',
        type: 'Actor',
        inbox: 'https://foo.test/inbox',
        featured: {
          type: 'OrderedCollection',
          orderedItems: ['https://example.com/statuses/1'],
        },
      }.deep_stringify_keys
    end

    it 'queues featured collection synchronization', :aggregate_failures do
      account = subject.call('alice', 'example.com', payload)

      expect(account.featured_collection_url).to eq ''
      expect(ActivityPub::SynchronizeFeaturedCollectionWorker).to have_enqueued_sidekiq_job(account.id, { 'hashtag' => true, 'request_id' => anything, 'collection' => payload['featured'] })
    end
  end

  context 'when account is not suspended' do
    subject { described_class.new.call(account.username, account.domain, payload) }

    let!(:account) { Fabricate(:account, username: 'alice', domain: 'example.com') }

    let(:payload) do
      {
        id: 'https://foo.test',
        type: 'Actor',
        inbox: 'https://foo.test/inbox',
        suspended: true,
      }.with_indifferent_access
    end

    before do
      allow(Admin::SuspensionWorker).to receive(:perform_async)
    end

    it 'suspends account remotely' do
      expect(subject.suspended?).to be true
      expect(subject.suspension_origin_remote?).to be true
    end

    it 'queues suspension worker' do
      subject
      expect(Admin::SuspensionWorker).to have_received(:perform_async)
    end
  end

  context 'when account is suspended' do
    subject { described_class.new.call('alice', 'example.com', payload) }

    let!(:account) { Fabricate(:account, username: 'alice', domain: 'example.com', display_name: '') }

    let(:payload) do
      {
        id: 'https://foo.test',
        type: 'Actor',
        inbox: 'https://foo.test/inbox',
        suspended: false,
        name: 'Hoge',
      }.with_indifferent_access
    end

    before do
      allow(Admin::UnsuspensionWorker).to receive(:perform_async)

      account.suspend!(origin: suspension_origin)
    end

    context 'when locally' do
      let(:suspension_origin) { :local }

      it 'does not unsuspend it' do
        expect(subject.suspended?).to be true
      end

      it 'does not update any attributes' do
        expect(subject.display_name).to_not eq 'Hoge'
      end
    end

    context 'when remotely' do
      let(:suspension_origin) { :remote }

      it 'unsuspends it' do
        expect(subject.suspended?).to be false
      end

      it 'queues unsuspension worker' do
        subject
        expect(Admin::UnsuspensionWorker).to have_received(:perform_async)
      end

      it 'updates attributes' do
        expect(subject.display_name).to eq 'Hoge'
      end
    end
  end

  context 'when discovering many subdomains in a short timeframe' do
    subject do
      8.times do |i|
        domain = "test#{i}.testdomain.com"
        json = {
          id: "https://#{domain}/users/1",
          type: 'Actor',
          inbox: "https://#{domain}/inbox",
        }.with_indifferent_access
        described_class.new.call('alice', domain, json)
      end
    end

    before do
      stub_const 'ActivityPub::ProcessAccountService::SUBDOMAINS_RATELIMIT', 5
    end

    it 'creates accounts without exceeding rate limit' do
      expect { subject }
        .to create_some_remote_accounts
        .and create_fewer_than_rate_limit_accounts
    end
  end

  context 'when Accounts referencing other accounts' do
    let(:payload) do
      {
        '@context': ['https://www.w3.org/ns/activitystreams'],
        id: 'https://foo.test/users/1',
        type: 'Person',
        inbox: 'https://foo.test/inbox',
        featured: 'https://foo.test/users/1/featured',
        preferredUsername: 'user1',
      }.with_indifferent_access
    end

    before do
      stub_const 'ActivityPub::ProcessAccountService::DISCOVERIES_PER_REQUEST', 5

      8.times do |i|
        actor_json = {
          '@context': ['https://www.w3.org/ns/activitystreams'],
          id: "https://foo.test/users/#{i}",
          type: 'Person',
          inbox: 'https://foo.test/inbox',
          featured: "https://foo.test/users/#{i}/featured",
          preferredUsername: "user#{i}",
        }.with_indifferent_access
        status_json = {
          '@context': ['https://www.w3.org/ns/activitystreams'],
          id: "https://foo.test/users/#{i}/status",
          attributedTo: "https://foo.test/users/#{i}",
          type: 'Note',
          content: "@user#{i + 1} test",
          tag: [
            {
              type: 'Mention',
              href: "https://foo.test/users/#{i + 1}",
              name: "@user#{i + 1}",
            },
          ],
          to: ['as:Public', "https://foo.test/users/#{i + 1}"],
        }.with_indifferent_access
        featured_json = {
          '@context': ['https://www.w3.org/ns/activitystreams'],
          id: "https://foo.test/users/#{i}/featured",
          type: 'OrderedCollection',
          totalItems: 1,
          orderedItems: [status_json],
        }.with_indifferent_access
        webfinger = {
          subject: "acct:user#{i}@foo.test",
          links: [{ rel: 'self', href: "https://foo.test/users/#{i}", type: 'application/activity+json' }],
        }.with_indifferent_access
        stub_request(:get, "https://foo.test/users/#{i}").to_return(status: 200, body: actor_json.to_json, headers: { 'Content-Type': 'application/activity+json' })
        stub_request(:get, "https://foo.test/users/#{i}/featured").to_return(status: 200, body: featured_json.to_json, headers: { 'Content-Type': 'application/activity+json' })
        stub_request(:get, "https://foo.test/users/#{i}/status").to_return(status: 200, body: status_json.to_json, headers: { 'Content-Type': 'application/activity+json' })
        stub_request(:get, "https://foo.test/.well-known/webfinger?resource=acct:user#{i}@foo.test").to_return(body: webfinger.to_json, headers: { 'Content-Type': 'application/jrd+json' })
      end
    end

    it 'creates accounts without exceeding rate limit', :inline_jobs do
      expect { subject.call('user1', 'foo.test', payload) }
        .to create_some_remote_accounts
        .and create_fewer_than_rate_limit_accounts
    end
  end

  context 'with interaction policy' do
    let(:payload) do
      {
        id: 'https://foo.test',
        type: 'Actor',
        inbox: 'https://foo.test/inbox',
        followers: 'https://foo.test/followers',
        following: 'https://foo.test/following',
        interactionPolicy: {
          canFeature: {
            automaticApproval: 'https://foo.test',
            manualApproval: [
              'https://foo.test/followers',
              'https://foo.test/following',
            ],
          },
        },
      }.with_indifferent_access
    end

    before do
      stub_request(:get, %r{^https://foo\.test/follow})
        .to_return(status: 200, body: '', headers: {})
    end

    # TODO: Remove when feature flag is removed
    context 'when collections feature is disabled' do
      it 'does not set the interaction policy' do
        account = subject.call('user1', 'foo.test', payload)

        expect(account.feature_approval_policy).to be_zero
      end
    end

    context 'when collections feature is enabled', feature: :collections do
      it 'sets the interaction policy to the correct value' do
        account = subject.call('user1', 'foo.test', payload)

        expect(account.feature_approval_policy).to eq 0b100000000000000001100
      end
    end
  end

  private

  def create_some_remote_accounts
    change(Account.remote, :count).by_at_least(2)
  end

  def create_fewer_than_rate_limit_accounts
    change(Account.remote, :count).by_at_most(5)
  end
end
