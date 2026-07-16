# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::ProcessAccountService do
  subject { described_class.new }

  def stub_webfinger!
    webfinger = {
      subject: "acct:#{payload['preferredUsername']}@#{Addressable::URI.parse(payload['id']).host}",
      links: [
        {
          rel: 'self',
          href: payload['id'],
          type: 'application/activity+json',
        },
      ],
    }.deep_stringify_keys
    stub_request(:get, "#{Addressable::URI.parse(payload['id']).origin}/.well-known/webfinger?resource=#{webfinger['subject']}").to_return(body: webfinger.to_json, headers: { 'Content-Type': 'application/jrd+json' })
  end

  context 'with property values, an avatar, and a profile header' do
    let(:payload) do
      {
        id: 'https://foo.test',
        type: 'Actor',
        inbox: 'https://foo.test/inbox',
        preferredUsername: 'alice',
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
      }.deep_stringify_keys
    end

    before do
      stub_webfinger!
      stub_request(:get, 'https://foo.test/image.png').to_return(request_fixture('avatar.txt'))
      stub_request(:get, 'https://foo.test/icon.png').to_return(request_fixture('avatar.txt'))
    end

    it 'parses property values, avatar and profile header as expected' do
      account = subject.call(payload)

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

  context 'with collection URIs' do
    let(:payload) do
      {
        'id' => 'https://foo.test',
        'type' => 'Actor',
        'preferredUsername' => 'alice',
        'inbox' => 'https://foo.test/inbox',
        'featured' => 'https://foo.test/featured',
        'followers' => 'https://foo.test/followers',
        'following' => 'https://foo.test/following',
        'featuredCollections' => 'https://foo.test/featured_collections',
      }
    end

    before do
      stub_webfinger!
      stub_request(:get, %r{^https://foo\.test/follow})
        .to_return(status: 200, body: '', headers: {})
    end

    it 'parses and sets the URIs, queues jobs to synchronize' do
      account = subject.call(payload)

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
      }.deep_stringify_keys
    end

    before { stub_webfinger! }

    it 'stores the key' do
      account = subject.call(payload)

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
      let!(:alice) { Fabricate(:account, uri: 'https://foo.test/actor', domain: 'foo.test', username: 'alice', legacy_keypair: true) }

      it 'invalidates the legacy key and stores the new key' do
        expect { subject.call(payload) }
          .to change { alice.reload.public_key }.to('')
          .and change { alice.reload.keypairs.to_a }.from([]).to(contain_exactly(have_attributes({ uri: 'https://foo.test/actor#key1', type: 'rsa', public_key: })))
      end
    end

    context 'when the account was known with an old key' do
      let!(:alice) { Fabricate(:account, uri: 'https://foo.test/actor', domain: 'foo.test', username: 'alice') }

      before do
        alice.keypairs.delete_all
        Fabricate(:keypair, account: alice, uri: 'https://foo.test/actor#old-key', type: :rsa)
      end

      it 'invalidates the old key and stores the new key' do
        expect { subject.call(payload) }
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
      stub_webfinger!
      stub_request(:get, key_id).to_return(status: 200, body: key_document.to_json, headers: { 'Content-Type': 'application/activity+json' })
    end

    it 'stores the key' do
      account = subject.call(payload)

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
        account = subject.call(payload)

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
      let!(:alice) { Fabricate(:account, uri: 'https://foo.test/actor', domain: 'foo.test', username: 'alice', legacy_keypair: true) }

      it 'invalidates the legacy key and stores the new key' do
        expect { subject.call(payload) }
          .to change { alice.reload.public_key }.to('')
          .and change { alice.reload.keypairs.to_a }.from([]).to(contain_exactly(have_attributes({ uri: key_id, type: 'rsa', public_key: })))
      end
    end

    context 'when the account was known with an old key' do
      let!(:alice) { Fabricate(:account, uri: 'https://foo.test/actor', domain: 'foo.test', username: 'alice') }

      before do
        alice.keypairs.delete_all
        Fabricate(:keypair, account: alice, uri: 'https://foo.test/actor#old-key', type: :rsa)
      end

      it 'invalidates the legacy key and stores the new key' do
        expect { subject.call(payload) }
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
      }.deep_stringify_keys
    end

    before { stub_webfinger! }

    it 'stores the keys' do
      account = subject.call(payload)

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
      let!(:alice) { Fabricate(:account, uri: 'https://foo.test/actor', domain: 'foo.test', username: 'alice', legacy_keypair: true) }

      it 'invalidates the legacy key and stores the new keys' do
        expect { subject.call(payload) }
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

  context 'with multiple keypairs using FEP-521a' do
    let(:payload) do
      {
        id: 'https://foo.test/actor',
        type: 'Actor',
        inbox: 'https://foo.test/inbox',
        preferredUsername: 'alice',
        assertionMethod: [
          {
            id: 'https://foo.test/actor#key1',
            type: 'Multikey',
            controller: 'https://foo.test/actor',
            publicKeyMultibase: 'z4MXj1wBzi9jUstyPMS4jQqB6KdJaiatPkAtVtGc6bQEQEEsKTic4G7Rou3iBf9vPmT5dbkm9qsZsuVNjq8HCuW1w24nhBFGkRE4cd2Uf2tfrB3N7h4mnyPp1BF3ZttHTYv3DLUPi1zMdkULiow3M1GfXkoC6DoxDUm1jmN6GBj22SjVsr6dxezRVQc7aj9TxE7JLbMH1wh5X3kA58H3DFW8rnYMakFGbca5CB2Jf6CnGQZmL7o5uJAdTwXfy2iiiyPxXEGerMhHwhjTA1mKYobyk2CpeEcmvynADfNZ5MBvcCS7m3XkFCMNUYBS9NQ3fze6vMSUPsNa6GVYmKx2x6JrdEjCk3qRMMmyjnjCMfR4pXbRMZa3i', # rubocop:disable Layout/LineLength
          },
          {
            id: 'https://foo.test/actor#key2',
            type: 'Multikey',
            controller: 'https://foo.test/actor',
            publicKeyMultibase: 'z2MGw4gk84USotaWf4AkJ83DcnrfgGaceF86KQXRYMfQ7xqnUG81FVWa2N5inzNigXsDkm2LxpuyYSajqZr1CwHqnJbVEw1rhN25tbJSFyej6TejRh3k67CK9nTVHdXFoVKgAFxLwgiqJwCyyYWesaQKXAQfwXYqCBxPyaDjFfWkya6xeLaNuKFYGLcVzZZQjL99dnzUpNiENFPkVmJokE1wKPpHttGpLgm9sizHNDFuwHaz2ZZRnnZ6CT95FzdrMmaDXofn1ikbKBTdumuiRWSVwwZXffcXRN6Ti1a8NfhxQDdqhT7CAmM9NjQhnrqs1vss6YdcrHP5GmQN2Mz8GenQZFnyhJZK2iPxETnxq7YJRqTduN8KC8SMfjLVB8LD7rBM5d6s8dopdgJCVBpy2p', # rubocop:disable Layout/LineLength
          },
        ],
      }.deep_stringify_keys
    end

    before { stub_webfinger! }

    it 'stores the keys' do
      account = subject.call(payload)

      expect(account.public_key).to eq ''
      expect(account.keypairs).to contain_exactly(
        have_attributes(
          uri: 'https://foo.test/actor#key1',
          type: 'rsa'
        ),
        have_attributes(
          uri: 'https://foo.test/actor#key2',
          type: 'rsa'
        )
      )
    end

    context 'when the account was known with a legacy key' do
      let!(:alice) { Fabricate(:account, uri: 'https://foo.test/actor', domain: 'foo.test', username: 'alice', legacy_keypair: true) }

      it 'invalidates the legacy key and stores the new keys' do
        expect { subject.call(payload) }
          .to change { alice.reload.public_key }.to('')
          .and change { alice.keypairs.to_a }.from([]).to(
            contain_exactly(
              have_attributes({ uri: 'https://foo.test/actor#key1', type: 'rsa' }),
              have_attributes({ uri: 'https://foo.test/actor#key2', type: 'rsa' })
            )
          )
      end
    end
  end

  context 'with an account that has changed URI but not handle (typically, losing Mastodon database)' do
    let!(:account) { Fabricate(:remote_account, username: 'alice', domain: 'example.com', uri: 'https://example.com/users/alice') }

    let(:payload) do
      {
        id: 'https://example.com/ap/users/1234',
        type: 'Actor',
        inbox: 'https://example.com/ap/users/1234/inbox',
        webfinger: 'alice@example.com',
        preferredUsername: 'alice',
        attachment: [
          { type: 'PropertyValue', name: 'Pronouns', value: 'They/them' },
          { type: 'PropertyValue', name: 'Occupation', value: 'Unit test' },
        ],
      }.deep_stringify_keys
    end

    before do
      stub_webfinger!
    end

    it 'properly updates the existing account, without creating a new one or calling AccountMergingWorker' do
      expect { subject.call(payload) }
        .to change { account.reload.uri }.from('https://example.com/users/alice').to('https://example.com/ap/users/1234')
        .and not_change { account.reload.acct }
        .and(not_change { Account.count })

      expect(AccountMergingWorker)
        .to_not have_enqueued_sidekiq_job(AccountMergingWorker)

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
    end
  end

  context 'with an account that has changed names through `webfinger` property' do
    let!(:account) { Fabricate(:remote_account, username: 'bob', domain: 'foo.test', uri: 'https://foo.test', inbox_url: 'https://foo.test/inbox') }

    let(:payload) do
      {
        id: 'https://foo.test',
        type: 'Actor',
        inbox: 'https://foo.test/inbox',
        webfinger: 'alice@example.com',
        attachment: [
          { type: 'PropertyValue', name: 'Pronouns', value: 'They/them' },
          { type: 'PropertyValue', name: 'Occupation', value: 'Unit test' },
        ],
      }.deep_stringify_keys
    end

    before do
      stub_webfinger!
      webfinger = {
        subject: 'acct:alice@example.com',
        links: [
          {
            rel: 'self',
            href: 'https://foo.test',
            type: 'application/activity+json',
          },
        ],
      }.deep_stringify_keys
      stub_request(:get, 'https://example.com/.well-known/webfinger?resource=acct:alice@example.com').to_return(body: webfinger.to_json, headers: { 'Content-Type': 'application/jrd+json' })
    end

    it 'parses property values, avatar and profile header as expected, updates account username without creating a new one or calling AccountMergingWorker' do
      expect { subject.call(payload) }
        .to change { account.reload.username }.from('bob').to('alice')
        .and change { account.reload.domain }.from('foo.test').to('example.com')
        .and not_change { account.reload.uri }
        .and(not_change { Account.count })

      expect(AccountMergingWorker)
        .to_not have_enqueued_sidekiq_job(AccountMergingWorker)

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
    end

    context 'when the destination handle is already occupied' do
      let!(:conflicting_account) { Fabricate(:remote_account, username: 'alice', domain: 'example.com', uri: 'https://foo.test/original_alice', inbox_url: 'https://foo.test/original_alice/inbox') }

      it 'updates the profile but does not touch the usernames or call AccountMergingWorker' do
        expect { subject.call(payload) }
          .to not_change { account.reload.username }
          .and not_change { account.reload.domain }
          .and not_change { account.reload.uri }
          .and not_change { conflicting_account.reload.acct }
          .and(not_change { Account.count })

        expect(AccountMergingWorker)
          .to_not have_enqueued_sidekiq_job

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
      end
    end
  end

  context 'with an account that has changed names and domain through `preferredUsername` property' do
    let!(:account) { Fabricate(:remote_account, username: 'bob', domain: 'foo.test', uri: 'https://foo.test', inbox_url: 'https://foo.test/inbox') }

    let(:payload) do
      {
        id: 'https://foo.test',
        type: 'Actor',
        inbox: 'https://foo.test/inbox',
        preferredUsername: 'alice',
        attachment: [
          { type: 'PropertyValue', name: 'Pronouns', value: 'They/them' },
          { type: 'PropertyValue', name: 'Occupation', value: 'Unit test' },
        ],
      }.deep_stringify_keys
    end

    before do
      stub_webfinger!
    end

    it 'parses property values, avatar and profile header as expected, updates account username without creating a new one or calling AccountMergingWorker' do
      expect { subject.call(payload) }
        .to change { account.reload.username }.from('bob').to('alice')
        .and not_change { account.reload.uri }
        .and(not_change { Account.count })

      expect(AccountMergingWorker)
        .to_not have_enqueued_sidekiq_job

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
    end

    context 'when the destination handle is already occupied' do
      let!(:conflicting_account) { Fabricate(:remote_account, username: 'alice', domain: 'foo.test', uri: 'https://foo.test/original_alice', inbox_url: 'https://foo.test/original_alice/inbox') }

      it 'updates the profile but does not touch the usernames or call AccountMergingWorker' do
        expect { subject.call(payload) }
          .to not_change { account.reload.username }
          .and not_change { account.reload.domain }
          .and not_change { account.reload.uri }
          .and not_change { conflicting_account.reload.acct }
          .and(not_change { Account.count })

        expect(AccountMergingWorker)
          .to_not have_enqueued_sidekiq_job

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
      end
    end
  end

  context 'with attribution domains' do
    let(:payload) do
      {
        id: 'https://foo.test',
        type: 'Actor',
        inbox: 'https://foo.test/inbox',
        preferredUsername: 'alice',
        attributionDomains: [
          'example.com',
        ],
      }.deep_stringify_keys
    end

    before { stub_webfinger! }

    it 'parses attribution domains' do
      account = subject.call(payload)

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
        preferredUsername: 'alice',
        showMedia: true,
        showRepliesInMedia: false,
        showFeatured: false,
      }.deep_stringify_keys
    end

    before { stub_webfinger! }

    it 'sets the profile settings as expected' do
      account = subject.call(payload)

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
        preferredUsername: 'alice',
        featured: {
          type: 'OrderedCollection',
          orderedItems: ['https://example.com/statuses/1'],
        },
      }.deep_stringify_keys
    end

    before { stub_webfinger! }

    it 'queues featured collection synchronization', :aggregate_failures do
      account = subject.call(payload)

      expect(account.featured_collection_url).to eq ''
      expect(ActivityPub::SynchronizeFeaturedCollectionWorker).to have_enqueued_sidekiq_job(account.id, { 'hashtag' => true, 'request_id' => anything, 'collection' => payload['featured'] })
    end
  end

  context 'when account is not suspended' do
    subject { described_class.new.call(payload) }

    let(:payload) do
      {
        id: 'https://example.com',
        preferredUsername: 'alice',
        type: 'Actor',
        inbox: 'https://example.com/inbox',
        suspended: true,
      }.deep_stringify_keys
    end

    before do
      stub_webfinger!

      Fabricate(:account, username: 'alice', domain: 'example.com')

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
    subject { described_class.new.call(payload) }

    let!(:account) { Fabricate(:account, username: 'alice', domain: 'example.com', display_name: '') }

    let(:payload) do
      {
        id: 'https://example.com',
        preferredUsername: 'alice',
        type: 'Actor',
        inbox: 'https://example.com/inbox',
        suspended: false,
        name: 'Hoge',
      }.deep_stringify_keys
    end

    before do
      stub_webfinger!

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
          preferredUsername: 'alice',
          type: 'Actor',
          inbox: "https://#{domain}/inbox",
        }.deep_stringify_keys
        described_class.new.call(json)
      end
    end

    before do
      stub_const 'ActivityPub::ProcessAccountService::SUBDOMAINS_RATELIMIT', 5

      8.times do |i|
        domain = "test#{i}.testdomain.com"

        webfinger = {
          subject: "acct:alice@#{domain}",
          links: [{ rel: 'self', href: "https://#{domain}/users/1", type: 'application/activity+json' }],
        }.deep_stringify_keys

        stub_request(:get, "https://#{domain}/.well-known/webfinger?resource=acct:alice@#{domain}").to_return(body: webfinger.to_json, headers: { 'Content-Type': 'application/jrd+json' })
      end
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
      }.deep_stringify_keys
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
        }.deep_stringify_keys
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
        }.deep_stringify_keys
        featured_json = {
          '@context': ['https://www.w3.org/ns/activitystreams'],
          id: "https://foo.test/users/#{i}/featured",
          type: 'OrderedCollection',
          totalItems: 1,
          orderedItems: [status_json],
        }.deep_stringify_keys
        webfinger = {
          subject: "acct:user#{i}@foo.test",
          links: [{ rel: 'self', href: "https://foo.test/users/#{i}", type: 'application/activity+json' }],
        }.deep_stringify_keys
        stub_request(:get, "https://foo.test/users/#{i}").to_return(status: 200, body: actor_json.to_json, headers: { 'Content-Type': 'application/activity+json' })
        stub_request(:get, "https://foo.test/users/#{i}/featured").to_return(status: 200, body: featured_json.to_json, headers: { 'Content-Type': 'application/activity+json' })
        stub_request(:get, "https://foo.test/users/#{i}/status").to_return(status: 200, body: status_json.to_json, headers: { 'Content-Type': 'application/activity+json' })
        stub_request(:get, "https://foo.test/.well-known/webfinger?resource=acct:user#{i}@foo.test").to_return(body: webfinger.to_json, headers: { 'Content-Type': 'application/jrd+json' })
      end
    end

    it 'creates accounts without exceeding rate limit', :inline_jobs do
      expect { subject.call(payload) }
        .to create_some_remote_accounts
        .and create_fewer_than_rate_limit_accounts
    end
  end

  context 'with interaction policy' do
    let(:payload) do
      {
        id: 'https://foo.test',
        preferredUsername: 'alice',
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
      }.deep_stringify_keys
    end

    before do
      stub_webfinger!

      stub_request(:get, %r{^https://foo\.test/follow})
        .to_return(status: 200, body: '', headers: {})
    end

    context 'when collections feature is enabled' do
      it 'sets the interaction policy to the correct value' do
        account = subject.call(payload)

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
