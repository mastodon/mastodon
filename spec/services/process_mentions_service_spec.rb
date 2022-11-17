require 'rails_helper'

RSpec.describe ProcessMentionsService, type: :service do
  let(:account) { Fabricate(:account, username: 'alice') }

  subject { ProcessMentionsService.new }

  context 'when mentions contain blocked accounts' do
    let(:non_blocked_account)          { Fabricate(:account) }
    let(:individually_blocked_account) { Fabricate(:account) }
    let(:domain_blocked_account)       { Fabricate(:account, domain: 'evil.com') }
    let(:status) { Fabricate(:status, account: account, text: "Hello @#{non_blocked_account.acct} @#{individually_blocked_account.acct} @#{domain_blocked_account.acct}", visibility: :public) }

    before do
      account.block!(individually_blocked_account)
      account.domain_blocks.create!(domain: domain_blocked_account.domain)

      subject.call(status)
    end

    it 'creates a mention to the non-blocked account' do
      expect(non_blocked_account.mentions.where(status: status).count).to eq 1
    end

    it 'does not create a mention to the individually blocked account' do
      expect(individually_blocked_account.mentions.where(status: status).count).to eq 0
    end

    it 'does not create a mention to the domain-blocked account' do
      expect(domain_blocked_account.mentions.where(status: status).count).to eq 0
    end
  end

  context 'resolving a mention to a remote account' do
    let(:status) { Fabricate(:status, account: account, text: "Hello @#{remote_user.acct}", visibility: :public) }

    context 'ActivityPub' do
      context do
        let!(:remote_user) { Fabricate(:account, username: 'remote_user', protocol: :activitypub, domain: 'example.com', inbox_url: 'http://example.com/inbox') }

        before do
          subject.call(status)
        end

        it 'creates a mention' do
          expect(remote_user.mentions.where(status: status).count).to eq 1
        end
      end

      context 'with an IDN domain' do
        let!(:remote_user) { Fabricate(:account, username: 'sneak', protocol: :activitypub, domain: 'xn--hresiar-mxa.ch', inbox_url: 'http://example.com/inbox') }
        let!(:status) { Fabricate(:status, account: account, text: "Hello @sneak@hæresiar.ch") }

        before do
          subject.call(status)
        end

        it 'creates a mention' do
          expect(remote_user.mentions.where(status: status).count).to eq 1
        end
      end

      context 'with an IDN TLD' do
        let!(:remote_user) { Fabricate(:account, username: 'foo', protocol: :activitypub, domain: 'xn--y9a3aq.xn--y9a3aq', inbox_url: 'http://example.com/inbox') }
        let!(:status) { Fabricate(:status, account: account, text: "Hello @foo@հայ.հայ") }

        before do
          subject.call(status)
        end

        it 'creates a mention' do
          expect(remote_user.mentions.where(status: status).count).to eq 1
        end
      end
    end

    context 'Temporarily-unreachable ActivityPub user' do
      let!(:remote_user) { Fabricate(:account, username: 'remote_user', protocol: :activitypub, domain: 'example.com', inbox_url: 'http://example.com/inbox', last_webfingered_at: nil) }

      before do
        stub_request(:get, "https://example.com/.well-known/host-meta").to_return(status: 404)
        stub_request(:get, "https://example.com/.well-known/webfinger?resource=acct:remote_user@example.com").to_return(status: 500)
        subject.call(status)
      end

      it 'creates a mention' do
        expect(remote_user.mentions.where(status: status).count).to eq 1
      end
    end
  end
end
