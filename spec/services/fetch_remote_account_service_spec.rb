require 'rails_helper'

RSpec.describe FetchRemoteAccountService, type: :service do
  let(:url) { 'https://example.com/alice' }
  let(:prefetched_body) { nil }
  let(:protocol) { :ostatus }
  subject { FetchRemoteAccountService.new.call(url, prefetched_body, protocol) }

  let(:actor) do
    {
      '@context': 'https://www.w3.org/ns/activitystreams',
      id: 'https://example.com/alice',
      type: 'Person',
      preferredUsername: 'alice',
      name: 'Alice',
      summary: 'Foo bar',
      inbox: 'http://example.com/alice/inbox',
    }
  end

  let(:webfinger) { { subject: 'acct:alice@example.com', links: [{ rel: 'self', href: 'https://example.com/alice' }] } }
  let(:xml) { File.read(Rails.root.join('spec', 'fixtures', 'xml', 'mastodon.atom')) }

  shared_examples 'return Account' do
    it { is_expected.to be_an Account }
  end

  context 'protocol is :activitypub' do
    let(:prefetched_body) { Oj.dump(actor) }
    let(:protocol) { :activitypub }

    before do
      stub_request(:get, 'https://example.com/.well-known/webfinger?resource=acct:alice@example.com').to_return(body: Oj.dump(webfinger), headers: { 'Content-Type': 'application/jrd+json' })
    end

    include_examples 'return Account'
  end

  context 'protocol is :ostatus' do
    let(:prefetched_body) { xml }
    let(:protocol) { :ostatus }

    before do
      stub_request(:get, "https://kickass.zone/.well-known/webfinger?resource=acct:localhost@kickass.zone").to_return(request_fixture('webfinger-hacker3.txt'))
      stub_request(:get, "https://kickass.zone/api/statuses/user_timeline/7477.atom").to_return(request_fixture('feed.txt'))
    end

    include_examples 'return Account'

    it 'does not update account information if XML comes from an unverified domain' do
      feed_xml = <<-XML.squish
        <?xml version="1.0" encoding="UTF-8"?>
        <feed xml:lang="en-US" xmlns="http://www.w3.org/2005/Atom" xmlns:thr="http://purl.org/syndication/thread/1.0" xmlns:georss="http://www.georss.org/georss" xmlns:activity="http://activitystrea.ms/spec/1.0/" xmlns:media="http://purl.org/syndication/atommedia" xmlns:poco="http://portablecontacts.net/spec/1.0" xmlns:ostatus="http://ostatus.org/schema/1.0" xmlns:statusnet="http://status.net/schema/api/1/">
          <author>
            <activity:object-type>http://activitystrea.ms/schema/1.0/person</activity:object-type>
            <uri>http://kickass.zone/users/localhost</uri>
            <name>localhost</name>
            <poco:preferredUsername>localhost</poco:preferredUsername>
            <poco:displayName>Villain!!!</poco:displayName>
          </author>
        </feed>
      XML

      returned_account = described_class.new.call('https://real-fake-domains.com/alice', feed_xml, :ostatus)
      expect(returned_account.display_name).to_not eq 'Villain!!!'
    end
  end

  context 'when prefetched_body is nil' do
    context 'protocol is :activitypub' do
      before do
        stub_request(:get, url).to_return(status: 200, body: Oj.dump(actor), headers: { 'Content-Type' => 'application/activity+json' })
        stub_request(:get, 'https://example.com/.well-known/webfinger?resource=acct:alice@example.com').to_return(body: Oj.dump(webfinger), headers: { 'Content-Type': 'application/jrd+json' })
      end

      include_examples 'return Account'
    end

    context 'protocol is :ostatus' do
      before do
        stub_request(:get, url).to_return(status: 200, body: xml, headers: { 'Content-Type' => 'application/atom+xml' })
        stub_request(:get, "https://kickass.zone/.well-known/webfinger?resource=acct:localhost@kickass.zone").to_return(request_fixture('webfinger-hacker3.txt'))
        stub_request(:get, "https://kickass.zone/api/statuses/user_timeline/7477.atom").to_return(request_fixture('feed.txt'))
      end

      include_examples 'return Account'
    end
  end
end
