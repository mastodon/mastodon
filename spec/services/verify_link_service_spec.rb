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

    context 'when a link contains an <a rel="noopener noreferrer"> back' do
      let(:html) do
        <<-HTML
          <!doctype html>
          <body>
            <a href="#{ActivityPub::TagManager.instance.url_for(account)}" rel="me noopener noreferrer" target="_blank">Follow me on Mastodon</a>
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

    context 'when a document is truncated but the link back is valid' do
      let(:html) do
        "
          <!doctype html>
          <body>
            <a rel=\"me\" href=\"#{ActivityPub::TagManager.instance.url_for(account)}\"
        "
      end

      it 'marks the field as not verified' do
        expect(field.verified?).to be false
      end
    end

    context 'when a link back might be truncated' do
      let(:html) do
        "
          <!doctype html>
          <body>
            <a rel=\"me\" href=\"#{ActivityPub::TagManager.instance.url_for(account)}"
      end

      it 'does not mark the field as verified' do
        expect(field.verified?).to be false
      end
    end

    context 'when a link does not contain a link back' do
      let(:html) { '' }

      it 'does not mark the field as verified' do
        expect(field.verified?).to be false
      end
    end

    context 'when link has no `href` attribute' do
      let(:html) do
        <<-HTML
          <!doctype html>
          <head>
            <link type="text/html" rel="me" />
          </head>
          <body>
            <a rel="me" target="_blank">Follow me on Mastodon</a>
          </body>
        HTML
      end

      it 'does not mark the field as verified' do
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
