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

  context 'when prefetched_body is nil' do
    context 'protocol is :activitypub' do
      before do
        stub_request(:get, url).to_return(status: 200, body: Oj.dump(actor), headers: { 'Content-Type' => 'application/activity+json' })
        stub_request(:get, 'https://example.com/.well-known/webfinger?resource=acct:alice@example.com').to_return(body: Oj.dump(webfinger), headers: { 'Content-Type': 'application/jrd+json' })
      end

      include_examples 'return Account'
    end
  end
end
