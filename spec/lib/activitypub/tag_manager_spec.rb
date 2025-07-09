# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::TagManager do
  include RoutingHelper

  subject { described_class.instance }

  let(:domain) { "#{Rails.configuration.x.use_https ? 'https' : 'http'}://#{Rails.configuration.x.web_domain}" }

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
    it 'returns a string starting with web domain' do
      account = Fabricate(:account)
      expect(subject.url_for(account)).to be_a(String)
        .and start_with(domain)
    end
  end

  describe '#uri_for' do
    it 'returns a string starting with web domain' do
      account = Fabricate(:account)
      expect(subject.uri_for(account)).to be_a(String)
        .and start_with(domain)
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
          .and start_with(domain)
      end
    end
  end

  describe '#to' do
    it 'returns public collection for public status' do
      status = Fabricate(:status, visibility: :public)
      expect(subject.to(status)).to eq ['https://www.w3.org/ns/activitystreams#Public']
    end

    it 'returns followers collection for unlisted status' do
      status = Fabricate(:status, visibility: :unlisted)
      expect(subject.to(status)).to eq [account_followers_url(status.account)]
    end

    it 'returns followers collection for private status' do
      status = Fabricate(:status, visibility: :private)
      expect(subject.to(status)).to eq [account_followers_url(status.account)]
    end

    it 'returns URIs of mentions for direct status' do
      status    = Fabricate(:status, visibility: :direct)
      mentioned = Fabricate(:account)
      status.mentions.create(account: mentioned)
      expect(subject.to(status)).to eq [subject.uri_for(mentioned)]
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
      status = Fabricate(:status, visibility: :public)
      expect(subject.cc(status)).to eq [account_followers_url(status.account)]
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
      status.mentions.create(account: mentioned)
      expect(subject.cc(status)).to include(subject.uri_for(mentioned))
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

  describe '#uri_to_local_id' do
    it 'returns the local ID' do
      account = Fabricate(:account)
      expect(subject.uri_to_local_id(subject.uri_for(account), :username)).to eq account.username
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
