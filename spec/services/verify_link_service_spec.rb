require 'rails_helper'

RSpec.describe VerifyLinkService, type: :service do
  subject { described_class.new }

  context 'given a local account' do
    let(:account) { Fabricate(:account, username: 'alice') }
    let(:field)   { Account::Field.new(account, 'name' => 'Website', 'value' => 'http://example.com') }

    before do
      stub_request(:head, 'https://redirect.me/abc').to_return(status: 301, headers: { 'Location' => ActivityPub::TagManager.instance.url_for(account) })
      stub_request(:get, 'http://example.com').to_return(status: 200, body: html)
      subject.call(field)
    end

    context 'when a link contains an <a> back' do
      let(:html) do
        <<-HTML
          <!doctype html>
          <body>
            <a href="#{ActivityPub::TagManager.instance.url_for(account)}" rel="me">Follow me on Mastodon</a>
          </body>
        HTML
      end

      it 'marks the field as verified' do
        expect(field.verified?).to be true
      end
    end

    context 'when a link contains an <a rel="noopener"> back' do
      let(:html) do
        <<-HTML
          <!doctype html>
          <body>
            <a href="#{ActivityPub::TagManager.instance.url_for(account)}" rel="noopener me" target="_blank">Follow me on Mastodon</a>
          </body>
        HTML
      end

      it 'marks the field as verified' do
        expect(field.verified?).to be true
      end
    end

    context 'when a link contains a <link> back' do
      let(:html) do
        <<-HTML
          <!doctype html>
          <head>
            <link type="text/html" href="#{ActivityPub::TagManager.instance.url_for(account)}" rel="me" />
          </head>
        HTML
      end

      it 'marks the field as verified' do
        expect(field.verified?).to be true
      end
    end

    context 'when a link goes through a redirect back' do
      let(:html) do
        <<-HTML
          <!doctype html>
          <head>
            <link type="text/html" href="https://redirect.me/abc" rel="me" />
          </head>
        HTML
      end

      it 'marks the field as verified' do
        expect(field.verified?).to be true
      end
    end

    context 'when a link does not contain a link back' do
      let(:html) { '' }

      it 'marks the field as verified' do
        expect(field.verified?).to be false
      end
    end
  end

  context 'given a remote account' do
    let(:account) { Fabricate(:account, username: 'alice', domain: 'example.com', url: 'https://profile.example.com/alice') }
    let(:field)   { Account::Field.new(account, 'name' => 'Website', 'value' => '<a href="http://example.com" rel="me"><span class="invisible">http://</span><span class="">example.com</span><span class="invisible"></span></a>') }

    before do
      stub_request(:get, 'http://example.com').to_return(status: 200, body: html)
      subject.call(field)
    end

    context 'when a link contains an <a> back' do
      let(:html) do
        <<-HTML
          <!doctype html>
          <body>
            <a href="https://profile.example.com/alice" rel="me">Follow me on Mastodon</a>
          </body>
        HTML
      end

      it 'marks the field as verified' do
        expect(field.verified?).to be true
      end
    end
  end
end
