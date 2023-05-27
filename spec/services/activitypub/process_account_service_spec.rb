# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::ProcessAccountService, type: :service do
  subject { described_class.new }

  context 'with property values' do
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
      }.with_indifferent_access
    end

    it 'parses out of attachment' do
      account = subject.call('alice', 'example.com', payload)
      expect(account.fields).to be_a Array
      expect(account.fields.size).to eq 2
      expect(account.fields[0]).to be_a Account::Field
      expect(account.fields[0].name).to eq 'Pronouns'
      expect(account.fields[0].value).to eq 'They/them'
      expect(account.fields[1]).to be_a Account::Field
      expect(account.fields[1].name).to eq 'Occupation'
      expect(account.fields[1].value).to eq 'Unit test'
    end
  end

  context 'when account is not suspended' do
    subject { described_class.new.call('alice', 'example.com', payload) }

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
    before do
      stub_const 'ActivityPub::ProcessAccountService::SUBDOMAINS_RATELIMIT', 5
    end

    let(:subject) do
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

    it 'creates at least some accounts' do
      expect { subject }.to change { Account.remote.count }.by_at_least(2)
    end

    it 'creates no more account than the limit allows' do
      expect { subject }.to change { Account.remote.count }.by_at_most(5)
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
          links: [{ rel: 'self', href: "https://foo.test/users/#{i}" }],
        }.with_indifferent_access
        stub_request(:get, "https://foo.test/users/#{i}").to_return(status: 200, body: actor_json.to_json, headers: { 'Content-Type': 'application/activity+json' })
        stub_request(:get, "https://foo.test/users/#{i}/featured").to_return(status: 200, body: featured_json.to_json, headers: { 'Content-Type': 'application/activity+json' })
        stub_request(:get, "https://foo.test/users/#{i}/status").to_return(status: 200, body: status_json.to_json, headers: { 'Content-Type': 'application/activity+json' })
        stub_request(:get, "https://foo.test/.well-known/webfinger?resource=acct:user#{i}@foo.test").to_return(body: webfinger.to_json, headers: { 'Content-Type': 'application/jrd+json' })
      end
    end

    it 'creates at least some accounts' do
      expect { subject.call('user1', 'foo.test', payload) }.to change { Account.remote.count }.by_at_least(2)
    end

    it 'creates no more account than the limit allows' do
      expect { subject.call('user1', 'foo.test', payload) }.to change { Account.remote.count }.by_at_most(5)
    end
  end
end
