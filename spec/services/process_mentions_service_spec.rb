# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProcessMentionsService do
  subject { described_class.new }

  let(:account) { Fabricate(:account, username: 'alice') }

  context 'when mentions contain blocked accounts' do
    let!(:non_blocked_account)          { Fabricate(:account) }
    let!(:individually_blocked_account) { Fabricate(:account) }
    let!(:domain_blocked_account)       { Fabricate(:account, domain: 'evil.com', protocol: :activitypub) }
    let(:status) { Fabricate(:status, account: account, text: "Hello @#{non_blocked_account.acct} @#{individually_blocked_account.acct} @#{domain_blocked_account.acct}", visibility: :public) }

    before do
      account.block!(individually_blocked_account)
      account.domain_blocks.create!(domain: domain_blocked_account.domain)
    end

    it 'creates a mention to the non-blocked account but not the individually or domain blocked accounts' do
      expect { subject.call(status) }
        .to create_mention_for_non_blocked
        .and skip_mention_for_individual
        .and skip_mention_for_domain_blocked
    end

    def create_mention_for_non_blocked
      change { non_blocked_account.mentions.where(status: status).count }.to(1)
    end

    def skip_mention_for_individual
      not_change { individually_blocked_account.mentions.where(status: status).count }.from(0)
    end

    def skip_mention_for_domain_blocked
      not_change { domain_blocked_account.mentions.where(status: status).count }.from(0)
    end
  end

  context 'with resolving a mention to a remote account' do
    let(:status) { Fabricate(:status, account: account, text: "Hello @#{remote_user.acct}", visibility: :public) }

    context 'with ActivityPub' do
      context 'with a valid remote user' do
        let!(:remote_user) { Fabricate(:account, username: 'remote_user', protocol: :activitypub, domain: 'example.com', inbox_url: 'http://example.com/inbox') }

        it 'creates a mention' do
          subject.call(status)

          expect(remote_user.mentions.where(status: status).count).to eq 1
        end
      end

      context 'when mentioning a user several times when not saving records' do
        let!(:remote_user) { Fabricate(:account, username: 'remote_user', protocol: :activitypub, domain: 'example.com', inbox_url: 'http://example.com/inbox') }
        let(:status)       { Fabricate(:status, account: account, text: "Hello @#{remote_user.acct} @#{remote_user.acct} @#{remote_user.acct}", visibility: :public) }

        it 'creates exactly one mention' do
          subject.call(status, save_records: false)

          expect(status.mentions.size).to eq 1
        end
      end

      context 'with an IDN domain' do
        let!(:remote_user) { Fabricate(:account, username: 'sneak', protocol: :activitypub, domain: 'xn--hresiar-mxa.ch', inbox_url: 'http://example.com/inbox') }
        let!(:status) { Fabricate(:status, account: account, text: 'Hello @sneak@hæresiar.ch') }

        it 'creates a mention' do
          subject.call(status)

          expect(remote_user.mentions.where(status: status).count).to eq 1
        end
      end

      context 'with an IDN TLD' do
        let!(:remote_user) { Fabricate(:account, username: 'foo', protocol: :activitypub, domain: 'xn--y9a3aq.xn--y9a3aq', inbox_url: 'http://example.com/inbox') }
        let!(:status) { Fabricate(:status, account: account, text: 'Hello @foo@հայ.հայ') }

        it 'creates a mention' do
          subject.call(status)

          expect(remote_user.mentions.where(status: status).count).to eq 1
        end
      end
    end

    context 'with a Temporarily-unreachable ActivityPub user' do
      let!(:remote_user) { Fabricate(:account, username: 'remote_user', protocol: :activitypub, domain: 'example.com', inbox_url: 'http://example.com/inbox', last_webfingered_at: nil) }

      before do
        stub_request(:get, 'https://example.com/.well-known/host-meta').to_return(status: 404)
        stub_request(:get, 'https://example.com/.well-known/webfinger?resource=acct:remote_user@example.com').to_return(status: 500)
      end

      it 'creates a mention' do
        subject.call(status)

        expect(remote_user.mentions.where(status: status).count).to eq 1
      end
    end
  end
end
