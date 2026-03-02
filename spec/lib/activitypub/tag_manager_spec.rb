# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::TagManager do
  include RoutingHelper

  subject { described_class.instance }

  let(:host_prefix) { "#{Rails.configuration.x.use_https ? 'https' : 'http'}://#{Rails.configuration.x.web_domain}" }

  describe '#public_collection?' do
    it 'returns true for the special public collection and common shorthands' do
      expect(subject.public_collection?('https://www.w3.org/ns/activitystreams#Public')).to be true
      expect(subject.public_collection?('as:Public')).to be true
      expect(subject.public_collection?('Public')).to be true
    end

    it 'returns false for other URIs' do
      expect(subject.public_collection?('https://example.com/foo/bar')).to be false
    end
  end

  describe '#url_for' do
    context 'with a local account' do
      let(:account) { Fabricate(:account, id_scheme: :username_ap_id) }

      it 'returns a string starting with web domain and with the expected path' do
        expect(subject.url_for(account))
          .to eq("#{host_prefix}/@#{account.username}")
      end

      context 'when using a numeric ID based scheme' do
        let(:account) { Fabricate(:account, id_scheme: :numeric_ap_id) }

        it 'returns a string starting with web domain and with the expected path' do
          expect(subject.url_for(account))
            .to eq("#{host_prefix}/@#{account.username}")
        end
      end
    end

    context 'with a remote account' do
      let(:account) { Fabricate(:account, domain: 'example.com', url: 'https://example.com/profiles/dskjfsdf') }

      it 'returns the expected URL' do
        expect(subject.url_for(account)).to eq account.url
      end
    end

    context 'with a local status' do
      let(:account) { Fabricate(:account, id_scheme: :username_ap_id) }
      let(:status) { Fabricate(:status, account: account) }

      it 'returns a string starting with web domain and with the expected path' do
        expect(subject.url_for(status))
          .to eq("#{host_prefix}/@#{status.account.username}/#{status.id}")
      end

      context 'when using a numeric ID based scheme' do
        let(:account) { Fabricate(:account, id_scheme: :numeric_ap_id) }

        it 'returns a string starting with web domain and with the expected path' do
          expect(subject.url_for(status))
            .to eq("#{host_prefix}/@#{status.account.username}/#{status.id}")
        end
      end
    end

    context 'with a remote status' do
      let(:account) { Fabricate(:account, domain: 'example.com', url: 'https://example.com/profiles/dskjfsdf') }
      let(:status) { Fabricate(:status, account: account, url: 'https://example.com/posts/1234') }

      it 'returns the expected URL' do
        expect(subject.url_for(status)).to eq status.url
      end
    end
  end

  describe '#uri_for' do
    context 'with the instance actor' do
      it 'returns a string starting with web domain and with the expected path' do
        expect(subject.uri_for(Account.representative))
          .to eq("#{host_prefix}/actor")
      end
    end

    context 'with a local account' do
      let(:account) { Fabricate(:account, id_scheme: :username_ap_id) }

      it 'returns a string starting with web domain and with the expected path' do
        expect(subject.uri_for(account))
          .to eq("#{host_prefix}/users/#{account.username}")
      end

      context 'when using a numeric ID based scheme' do
        let(:account) { Fabricate(:account, id_scheme: :numeric_ap_id) }

        it 'returns a string starting with web domain and with the expected path' do
          expect(subject.uri_for(account))
            .to eq("#{host_prefix}/ap/users/#{account.id}")
        end
      end
    end

    context 'with a remote account' do
      let(:account) { Fabricate(:account, domain: 'example.com', uri: 'https://example.com/profiles/dskjfsdf') }

      it 'returns the expected URL' do
        expect(subject.uri_for(account)).to eq account.uri
      end
    end

    context 'with a local status' do
      let(:account) { Fabricate(:account, id_scheme: :username_ap_id) }
      let(:status) { Fabricate(:status, account: account) }

      it 'returns a string starting with web domain and with the expected path' do
        expect(subject.uri_for(status))
          .to eq("#{host_prefix}/users/#{status.account.username}/statuses/#{status.id}")
      end

      context 'when using a numeric ID based scheme' do
        let(:account) { Fabricate(:account, id_scheme: :numeric_ap_id) }

        it 'returns a string starting with web domain and with the expected path' do
          expect(subject.uri_for(status))
            .to eq("#{host_prefix}/ap/users/#{status.account.id}/statuses/#{status.id}")
        end
      end

      context 'with a reblog' do
        let(:status) { Fabricate(:status, account:, reblog: Fabricate(:status)) }

        context 'when using a numeric ID based scheme' do
          let(:account) { Fabricate(:account, id_scheme: :numeric_ap_id) }

          it 'returns a string starting with web domain and with the expected path' do
            expect(subject.uri_for(status))
              .to eq("#{host_prefix}/ap/users/#{status.account.id}/statuses/#{status.id}/activity")
          end
        end

        context 'when using the legacy username based scheme' do
          let(:account) { Fabricate(:account, id_scheme: :username_ap_id) }

          it 'returns a string starting with web domain and with the expected path' do
            expect(subject.uri_for(status))
              .to eq("#{host_prefix}/users/#{status.account.username}/statuses/#{status.id}/activity")
          end
        end
      end
    end

    context 'with a remote status' do
      let(:account) { Fabricate(:account, domain: 'example.com', uri: 'https://example.com/profiles/dskjfsdf') }
      let(:status) { Fabricate(:status, account: account, uri: 'https://example.com/posts/1234') }

      it 'returns the expected URL' do
        expect(subject.uri_for(status)).to eq status.uri
      end
    end

    context 'with a local conversation' do
      let(:account) { Fabricate(:account, id_scheme: :username_ap_id) }
      let(:status) { Fabricate(:status, account: account) }

      it 'returns a string starting with web domain and with the expected path' do
        expect(subject.uri_for(status.conversation))
          .to eq("#{host_prefix}/contexts/#{status.account.id}-#{status.id}")
      end

      context 'when using a numeric ID based scheme' do
        let(:account) { Fabricate(:account, id_scheme: :numeric_ap_id) }

        it 'returns a string starting with web domain and with the expected path' do
          expect(subject.uri_for(status.conversation))
            .to eq("#{host_prefix}/contexts/#{status.account.id}-#{status.id}")
        end
      end
    end

    context 'with a remote conversation' do
      let(:account) { Fabricate(:account, domain: 'example.com', uri: 'https://example.com/profiles/dskjfsdf') }
      let(:status) { Fabricate(:status, account: account, uri: 'https://example.com/posts/1234') }

      before do
        status.conversation.update!(uri: 'https://example.com/conversations/1234')
      end

      it 'returns the expected URL' do
        expect(subject.uri_for(status.conversation)).to eq status.conversation.uri
      end
    end

    context 'with a local collection' do
      let(:collection) { Fabricate(:collection) }

      it 'returns a string starting with web domain and with the expected path' do
        expect(subject.uri_for(collection))
          .to eq("#{host_prefix}/ap/users/#{collection.account.id}/collections/#{collection.id}")
      end
    end

    context 'with a remote collection' do
      let(:collection) { Fabricate(:remote_collection) }

      it 'returns the expected URL' do
        expect(subject.uri_for(collection)).to eq collection.uri
      end
    end
  end

  describe '#key_uri_for' do
    context 'with the instance actor' do
      it 'returns a string starting with web domain and with the expected path' do
        expect(subject.key_uri_for(Account.representative))
          .to eq("#{host_prefix}/actor#main-key")
      end
    end

    context 'with a local account' do
      let(:account) { Fabricate(:account, id_scheme: :username_ap_id) }

      it 'returns a string starting with web domain and with the expected path' do
        expect(subject.key_uri_for(account))
          .to eq("#{host_prefix}/users/#{account.username}#main-key")
      end

      context 'when using a numeric ID based scheme' do
        let(:account) { Fabricate(:account, id_scheme: :numeric_ap_id) }

        it 'returns a string starting with web domain and with the expected path' do
          expect(subject.key_uri_for(account))
            .to eq("#{host_prefix}/ap/users/#{account.id}#main-key")
        end
      end
    end
  end

  describe '#activity_uri_for' do
    context 'when given an account' do
      it 'raises an exception' do
        account = Fabricate(:account)
        expect { subject.activity_uri_for(account) }.to raise_error(ArgumentError)
      end
    end

    context 'when given a local activity' do
      it 'returns a string starting with web domain' do
        status = Fabricate(:status)
        expect(subject.uri_for(status)).to be_a(String)
          .and start_with(host_prefix)
      end
    end
  end

  describe '#approval_uri_for' do
    context 'with a valid local approval' do
      let(:quoted_account) { Fabricate(:account, id_scheme: :username_ap_id) }
      let(:quoted_status) { Fabricate(:status, account: quoted_account) }
      let(:quote) { Fabricate(:quote, state: :accepted, quoted_status: quoted_status) }

      it 'returns a string with the web domain and expected path' do
        expect(subject.approval_uri_for(quote))
          .to eq("#{host_prefix}/users/#{quote.quoted_account.username}/quote_authorizations/#{quote.id}")
      end

      context 'when using a numeric ID based scheme' do
        let(:quoted_account) { Fabricate(:account, id_scheme: :numeric_ap_id) }

        it 'returns a string with the web domain and expected path' do
          expect(subject.approval_uri_for(quote))
            .to eq("#{host_prefix}/ap/users/#{quote.quoted_account_id}/quote_authorizations/#{quote.id}")
        end
      end
    end

    context 'with an unapproved local quote' do
      let(:quoted_account) { Fabricate(:account, id_scheme: :username_ap_id) }
      let(:quoted_status) { Fabricate(:status, account: quoted_account) }
      let(:quote) { Fabricate(:quote, state: :rejected, quoted_status: quoted_status) }

      it 'returns nil' do
        expect(subject.approval_uri_for(quote))
          .to be_nil
      end

      context 'when using a numeric ID based scheme' do
        let(:quoted_account) { Fabricate(:account, id_scheme: :numeric_ap_id) }

        it 'returns nil' do
          expect(subject.approval_uri_for(quote))
            .to be_nil
        end
      end
    end

    context 'with a valid remote approval' do
      let(:quoted_account) { Fabricate(:account, domain: 'example.com') }
      let(:quoted_status) { Fabricate(:status, account: quoted_account) }
      let(:quote) { Fabricate(:quote, status: Fabricate(:status), state: :accepted, quoted_status: quoted_status, approval_uri: 'https://example.com/approvals/1') }

      it 'returns the expected URI' do
        expect(subject.approval_uri_for(quote)).to eq quote.approval_uri
      end
    end

    context 'with an unapproved local quote but check_approval override' do
      let(:quoted_account) { Fabricate(:account, id_scheme: :username_ap_id) }
      let(:quoted_status) { Fabricate(:status, account: quoted_account) }
      let(:quote) { Fabricate(:quote, state: :rejected, quoted_status: quoted_status) }

      it 'returns a string with the web domain and expected path' do
        expect(subject.approval_uri_for(quote, check_approval: false))
          .to eq("#{host_prefix}/users/#{quote.quoted_account.username}/quote_authorizations/#{quote.id}")
      end

      context 'when using a numeric ID based scheme' do
        let(:quoted_account) { Fabricate(:account, id_scheme: :numeric_ap_id) }

        it 'returns a string with the web domain and expected path' do
          expect(subject.approval_uri_for(quote, check_approval: false))
            .to eq("#{host_prefix}/ap/users/#{quote.quoted_account_id}/quote_authorizations/#{quote.id}")
        end
      end
    end
  end

  describe '#replies_uri_for' do
    context 'with a local status' do
      let(:account) { Fabricate(:account, id_scheme: :username_ap_id) }
      let(:status) { Fabricate(:status, account: account) }

      it 'returns a string starting with web domain and with the expected path' do
        expect(subject.replies_uri_for(status))
          .to eq("#{host_prefix}/users/#{status.account.username}/statuses/#{status.id}/replies")
      end

      context 'when using a numeric ID based scheme' do
        let(:account) { Fabricate(:account, id_scheme: :numeric_ap_id) }

        it 'returns a string starting with web domain and with the expected path' do
          expect(subject.replies_uri_for(status))
            .to eq("#{host_prefix}/ap/users/#{status.account.id}/statuses/#{status.id}/replies")
        end
      end
    end
  end

  describe '#likes_uri_for' do
    context 'with a local status' do
      let(:account) { Fabricate(:account, id_scheme: :username_ap_id) }
      let(:status) { Fabricate(:status, account: account) }

      it 'returns a string starting with web domain and with the expected path' do
        expect(subject.likes_uri_for(status))
          .to eq("#{host_prefix}/users/#{status.account.username}/statuses/#{status.id}/likes")
      end

      context 'when using a numeric ID based scheme' do
        let(:account) { Fabricate(:account, id_scheme: :numeric_ap_id) }

        it 'returns a string starting with web domain and with the expected path' do
          expect(subject.likes_uri_for(status))
            .to eq("#{host_prefix}/ap/users/#{status.account.id}/statuses/#{status.id}/likes")
        end
      end
    end
  end

  describe '#shares_uri_for' do
    context 'with a local status' do
      let(:account) { Fabricate(:account, id_scheme: :username_ap_id) }
      let(:status) { Fabricate(:status, account: account) }

      it 'returns a string starting with web domain and with the expected path' do
        expect(subject.shares_uri_for(status))
          .to eq("#{host_prefix}/users/#{status.account.username}/statuses/#{status.id}/shares")
      end

      context 'when using a numeric ID based scheme' do
        let(:account) { Fabricate(:account, id_scheme: :numeric_ap_id) }

        it 'returns a string starting with web domain and with the expected path' do
          expect(subject.shares_uri_for(status))
            .to eq("#{host_prefix}/ap/users/#{status.account.id}/statuses/#{status.id}/shares")
        end
      end
    end
  end

  describe '#following_uri_for' do
    context 'with a local account' do
      let(:account) { Fabricate(:account, id_scheme: :username_ap_id) }

      it 'returns a string starting with web domain and with the expected path' do
        expect(subject.following_uri_for(account))
          .to eq("#{host_prefix}/users/#{account.username}/following")
      end

      context 'when using a numeric ID based scheme' do
        let(:account) { Fabricate(:account, id_scheme: :numeric_ap_id) }

        it 'returns a string starting with web domain and with the expected path' do
          expect(subject.following_uri_for(account))
            .to eq("#{host_prefix}/ap/users/#{account.id}/following")
        end
      end
    end
  end

  describe '#followers_uri_for' do
    context 'with a local account' do
      let(:account) { Fabricate(:account, id_scheme: :username_ap_id) }

      it 'returns a string starting with web domain and with the expected path' do
        expect(subject.followers_uri_for(account))
          .to eq("#{host_prefix}/users/#{account.username}/followers")
      end

      context 'when using a numeric ID based scheme' do
        let(:account) { Fabricate(:account, id_scheme: :numeric_ap_id) }

        it 'returns a string starting with web domain and with the expected path' do
          expect(subject.followers_uri_for(account))
            .to eq("#{host_prefix}/ap/users/#{account.id}/followers")
        end
      end
    end
  end

  describe '#inbox_uri_for' do
    context 'with the instance actor' do
      it 'returns a string starting with web domain and with the expected path' do
        expect(subject.inbox_uri_for(Account.representative))
          .to eq("#{host_prefix}/actor/inbox")
      end
    end

    context 'with a local account' do
      let(:account) { Fabricate(:account, id_scheme: :username_ap_id) }

      it 'returns a string starting with web domain and with the expected path' do
        expect(subject.inbox_uri_for(account))
          .to eq("#{host_prefix}/users/#{account.username}/inbox")
      end

      context 'when using a numeric ID based scheme' do
        let(:account) { Fabricate(:account, id_scheme: :numeric_ap_id) }

        it 'returns a string starting with web domain and with the expected path' do
          expect(subject.inbox_uri_for(account))
            .to eq("#{host_prefix}/ap/users/#{account.id}/inbox")
        end
      end
    end
  end

  describe '#outbox_uri_for' do
    context 'with the instance actor' do
      it 'returns a string starting with web domain and with the expected path' do
        expect(subject.outbox_uri_for(Account.representative))
          .to eq("#{host_prefix}/actor/outbox")
      end
    end

    context 'with a local account' do
      let(:account) { Fabricate(:account, id_scheme: :username_ap_id) }

      it 'returns a string starting with web domain and with the expected path' do
        expect(subject.outbox_uri_for(account))
          .to eq("#{host_prefix}/users/#{account.username}/outbox")
      end

      context 'when using a numeric ID based scheme' do
        let(:account) { Fabricate(:account, id_scheme: :numeric_ap_id) }

        it 'returns a string starting with web domain and with the expected path' do
          expect(subject.outbox_uri_for(account))
            .to eq("#{host_prefix}/ap/users/#{account.id}/outbox")
        end
      end
    end
  end

  describe '#to' do
    it 'returns public collection for public status' do
      status = Fabricate(:status, visibility: :public)
      expect(subject.to(status)).to eq ['https://www.w3.org/ns/activitystreams#Public']
    end

    it 'returns followers collection for unlisted status' do
      status = Fabricate(:status, visibility: :unlisted, account: Fabricate(:account, id_scheme: :username_ap_id))
      expect(subject.to(status)).to eq [account_followers_url(status.account)]
    end

    it 'returns followers collection for unlisted status when using a numeric ID based scheme' do
      status = Fabricate(:status, visibility: :unlisted, account: Fabricate(:account, id_scheme: :numeric_ap_id))
      expect(subject.to(status)).to eq [ap_account_followers_url(status.account_id)]
    end

    it 'returns followers collection for private status' do
      status = Fabricate(:status, visibility: :private, account: Fabricate(:account, id_scheme: :username_ap_id))
      expect(subject.to(status)).to eq [account_followers_url(status.account)]
    end

    it 'returns followers collection for private status when using a numeric ID based scheme' do
      status = Fabricate(:status, visibility: :private, account: Fabricate(:account, id_scheme: :numeric_ap_id))
      expect(subject.to(status)).to eq [ap_account_followers_url(status.account_id)]
    end

    it 'returns URIs of mentions for direct status' do
      status    = Fabricate(:status, visibility: :direct)
      mentioned = Fabricate(:account)
      mentioned_numeric = Fabricate(:account, id_scheme: :numeric_ap_id)
      status.mentions.create(account: mentioned)
      status.mentions.create(account: mentioned_numeric)
      expect(subject.to(status)).to eq [subject.uri_for(mentioned), subject.uri_for(mentioned_numeric)]
    end

    it "returns URIs of mentioned group's followers for direct statuses to groups" do
      status    = Fabricate(:status, visibility: :direct)
      mentioned = Fabricate(:account, domain: 'remote.org', uri: 'https://remote.org/group', followers_url: 'https://remote.org/group/followers', actor_type: 'Group')
      status.mentions.create(account: mentioned)
      expect(subject.to(status)).to include(subject.uri_for(mentioned))
      expect(subject.to(status)).to include(subject.followers_uri_for(mentioned))
    end

    context 'with followers and requested followers' do
      let!(:bob) { Fabricate(:account, username: 'bob') }
      let!(:alice) { Fabricate(:account, username: 'alice') }
      let!(:foo) { Fabricate(:account) }
      let!(:author) { Fabricate(:account, username: 'author', silenced: true) }
      let!(:status) { Fabricate(:status, visibility: :direct, account: author) }

      before do
        bob.follow!(author)
        FollowRequest.create!(account: foo, target_account: author)
        status.mentions.create(account: alice)
        status.mentions.create(account: bob)
        status.mentions.create(account: foo)
      end

      it "returns URIs of mentions for direct silenced author's status only if they are followers or requesting to be" do
        expect(subject.to(status))
          .to include(subject.uri_for(bob))
          .and include(subject.uri_for(foo))
          .and not_include(subject.uri_for(alice))
      end
    end
  end

  describe '#cc' do
    it 'returns followers collection for public status' do
      status = Fabricate(:status, visibility: :public, account: Fabricate(:account, id_scheme: :username_ap_id))
      expect(subject.cc(status)).to eq [account_followers_url(status.account)]
    end

    it 'returns followers collection for public status when using a numeric ID based scheme' do
      status = Fabricate(:status, visibility: :public, account: Fabricate(:account, id_scheme: :numeric_ap_id))
      expect(subject.cc(status)).to eq [ap_account_followers_url(status.account_id)]
    end

    it 'returns public collection for unlisted status' do
      status = Fabricate(:status, visibility: :unlisted)
      expect(subject.cc(status)).to eq ['https://www.w3.org/ns/activitystreams#Public']
    end

    it 'returns empty array for private status' do
      status = Fabricate(:status, visibility: :private)
      expect(subject.cc(status)).to eq []
    end

    it 'returns empty array for direct status' do
      status = Fabricate(:status, visibility: :direct)
      expect(subject.cc(status)).to eq []
    end

    it 'returns URIs of mentions for non-direct status' do
      status    = Fabricate(:status, visibility: :public)
      mentioned = Fabricate(:account)
      mentioned_numeric = Fabricate(:account, id_scheme: :numeric_ap_id)
      status.mentions.create(account: mentioned)
      status.mentions.create(account: mentioned_numeric)
      expect(subject.cc(status)).to include(subject.uri_for(mentioned), subject.uri_for(mentioned_numeric))
    end

    context 'with followers and requested followers' do
      let!(:bob) { Fabricate(:account, username: 'bob') }
      let!(:alice) { Fabricate(:account, username: 'alice') }
      let!(:foo) { Fabricate(:account) }
      let!(:author) { Fabricate(:account, username: 'author', silenced: true) }
      let!(:status) { Fabricate(:status, visibility: :public, account: author) }

      before do
        bob.follow!(author)
        FollowRequest.create!(account: foo, target_account: author)
        status.mentions.create(account: alice)
        status.mentions.create(account: bob)
        status.mentions.create(account: foo)
      end

      it "returns URIs of mentions for silenced author's non-direct status only if they are followers or requesting to be" do
        expect(subject.cc(status))
          .to include(subject.uri_for(bob))
          .and include(subject.uri_for(foo))
          .and not_include(subject.uri_for(alice))
      end
    end

    it 'returns poster of reblogged post, if reblog' do
      bob    = Fabricate(:account, username: 'bob', domain: 'example.com', inbox_url: 'http://example.com/bob')
      alice  = Fabricate(:account, username: 'alice')
      status = Fabricate(:status, visibility: :public, account: bob)
      reblog = Fabricate(:status, visibility: :public, account: alice, reblog: status)
      expect(subject.cc(reblog)).to include(subject.uri_for(bob))
    end
  end

  describe '#local_uri?' do
    it 'returns false for non-local URI' do
      expect(subject.local_uri?('http://example.com/123')).to be false
    end

    it 'returns true for local URIs' do
      account = Fabricate(:account)
      expect(subject.local_uri?(subject.uri_for(account))).to be true
    end
  end

  describe '#uris_to_local_accounts' do
    it 'returns the expected local accounts' do
      account = Fabricate(:account)
      expect(subject.uris_to_local_accounts([subject.uri_for(account), instance_actor_url])).to contain_exactly(account, Account.representative)
    end

    it 'does not return remote accounts' do
      account = Fabricate(:account, uri: 'https://example.com/123', domain: 'example.com')
      expect(subject.uris_to_local_accounts([subject.uri_for(account)])).to be_empty
    end

    it 'does not return an account for a local post' do
      status = Fabricate(:status)
      expect(subject.uris_to_local_accounts([subject.uri_for(status)])).to be_empty
    end
  end

  describe '#uri_to_resource' do
    it 'returns the local account' do
      account = Fabricate(:account)
      expect(subject.uri_to_resource(subject.uri_for(account), Account)).to eq account
    end

    it 'returns the remote account by matching URI without fragment part' do
      account = Fabricate(:account, uri: 'https://example.com/123', domain: 'example.com')
      expect(subject.uri_to_resource('https://example.com/123#456', Account)).to eq account
    end

    it 'returns the local status for ActivityPub URI' do
      status = Fabricate(:status)
      expect(subject.uri_to_resource(subject.uri_for(status), Status)).to eq status
    end

    it 'returns the local status for OStatus tag: URI' do
      status = Fabricate(:status)
      expect(subject.uri_to_resource(OStatus::TagManager.instance.uri_for(status), Status)).to eq status
    end

    it 'returns the remote status by matching URI without fragment part' do
      status = Fabricate(:status, uri: 'https://example.com/123')
      expect(subject.uri_to_resource('https://example.com/123#456', Status)).to eq status
    end
  end
end
