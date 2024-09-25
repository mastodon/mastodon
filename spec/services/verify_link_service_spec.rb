# frozen_string_literal: true

require 'rails_helper'

RSpec.describe VerifyLinkService do
  subject { described_class.new }

  context 'when given a local account' do
    let(:account) { Fabricate(:account, username: 'alice') }
    let(:field)   { Account::Field.new(account, 'name' => 'Website', 'value' => 'http://example.com') }

    before do
      stub_request(:head, 'https://redirect.me/abc').to_return(status: 301, headers: { 'Location' => ActivityPub::TagManager.instance.url_for(account) })
      stub_request(:head, 'http://unrelated-site.com').to_return(status: 301)
      stub_request(:get, 'http://example.com').to_return(status: 200, body: html)
      subject.call(field)
    end

    context 'when a link contains an <a> back' do
      let(:html) do
        <<~HTML
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

    context 'when a link contains an <a rel="me noopener noreferrer"> back' do
      let(:html) do
        <<~HTML
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
        <<~HTML
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
        <<~HTML
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
        <<-HTML
          <!doctype html>
          <body>
            <a rel="me" href="#{ActivityPub::TagManager.instance.url_for(account)}">
        HTML
      end

      it 'marks the field as verified' do
        expect(field.verified?).to be true
      end
    end

    context 'when a link tag might be truncated' do
      let(:html) do
        <<-HTML_TRUNCATED
          <!doctype html>
          <body>
            <a rel="me" href="#{ActivityPub::TagManager.instance.url_for(account)}"
        HTML_TRUNCATED
      end

      it 'marks the field as not verified' do
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
        <<~HTML
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

    context 'when a link contains a link to an unexpected URL' do
      let(:html) do
        <<~HTML
          <!doctype html>
          <body>
            <a href="http://unrelated-site.com" rel="me">Follow me on Unrelated Site</a>
          </body>
        HTML
      end

      it 'does not mark the field as verified' do
        expect(field.verified?).to be false
      end
    end
  end

  context 'when given a remote account' do
    let(:account) { Fabricate(:account, username: 'alice', domain: 'example.com', url: 'https://profile.example.com/alice') }
    let(:field)   { Account::Field.new(account, 'name' => 'Website', 'value' => '<a href="http://example.com" rel="me"><span class="invisible">http://</span><span class="">example.com</span><span class="invisible"></span></a>') }

    before do
      stub_request(:get, 'http://example.com').to_return(status: 200, body: html)
      subject.call(field)
    end

    context 'when a link contains an <a> back' do
      let(:html) do
        <<~HTML
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

    context 'when the link contains a link with a missing protocol slash' do
      # This was seen in the wild where a user had three pages:
      # 1. their mastodon profile, which linked to github and the personal website
      # 2. their personal website correctly linking back to mastodon
      # 3. a github profile that was linking to the personal website, but with
      #    a malformed protocol of http:/
      #
      # This caused link verification between the mastodon profile and the
      # website to fail.
      #
      # apparently github allows the user to enter website URLs with a single
      # slash and makes no attempts to correct that.
      let(:html) do
        <<-HTML
          <a href="http:/unrelated.example">Hello</a>
        HTML
      end

      it 'does not crash' do
        # We could probably put more effort into perhaps auto-correcting the
        # link and following it anyway, but at the very least we shouldn't let
        # exceptions bubble up
        expect(field.verified?).to be false
      end
    end
  end
end
