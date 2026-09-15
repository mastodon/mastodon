# frozen_string_literal: true

require 'rails_helper'

RSpec.describe VerifyLinkService do
  subject { described_class.new }

  context 'when given a local account' do
    let(:account) { Fabricate(:account, username: 'alice') }
    let(:field)   { Account::Field.new(account, 'name' => 'Website', 'value' => 'http://example.com') }
    let(:link_back) { ActivityPub::TagManager.instance.url_for(account) }
    let(:response_status) { 200 }
    let(:response_headers) { {} }

    before do
      stub_request(:head, 'https://redirect.me/abc').to_return(status: 301, headers: { 'Location' => link_back })
      stub_request(:head, 'http://unrelated-site.com').to_return(status: 301)
      stub_request(:get, 'http://example.com').to_return(status: response_status, body: html, headers: response_headers)
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

    context 'when a link contains an <a rel=ME> back' do
      let(:html) do
        <<~HTML
          <!doctype html>
          <body>
            <a href="#{ActivityPub::TagManager.instance.url_for(account)}" rel=ME>Follow me on Mastodon</a>
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

    context 'when the response carries a Link header' do
      let(:html) do
        <<~HTML
          <!doctype html>
          <body>
            <p>This page has no rel="me" links in its markup.</p>
          </body>
        HTML
      end

      context 'when the header has rel="me" back' do
        let(:response_headers) { { 'Link' => "<#{link_back}>; rel=\"me\"" } }

        it 'marks the field as verified' do
          expect(field.verified?).to be true
        end
      end

      context 'when the header quotes the rel value with single quotes' do
        let(:response_headers) { { 'Link' => "<#{link_back}>; rel='me'" } }

        it 'marks the field as verified' do
          expect(field.verified?).to be true
        end
      end

      context 'when the header uses uppercase REL="ME"' do
        let(:response_headers) { { 'Link' => "<#{link_back}>; REL=\"ME\"" } }

        it 'marks the field as verified' do
          expect(field.verified?).to be true
        end
      end

      context 'when the header URL differs from the link back only by case' do
        let(:response_headers) { { 'Link' => "<#{link_back.upcase}>; rel=\"me\"" } }

        it 'marks the field as verified' do
          expect(field.verified?).to be true
        end
      end

      context 'when only one of several Link headers links back' do
        let(:response_headers) { { 'Link' => ['<http://unrelated-site.com>; rel="me"', "<#{link_back}>; rel=\"me\""] } }

        it 'marks the field as verified' do
          expect(field.verified?).to be true
        end
      end

      context 'when the header links back with a rel other than me' do
        let(:response_headers) { { 'Link' => "<#{link_back}>; rel=\"canonical\"" } }

        it 'does not mark the field as verified' do
          expect(field.verified?).to be false
        end
      end

      context 'when the header links to an unexpected URL' do
        let(:response_headers) { { 'Link' => '<http://unrelated-site.com>; rel="me"' } }

        it 'does not mark the field as verified' do
          expect(field.verified?).to be false
        end
      end

      context 'when the header links to an unexpected URL but the markup links back' do
        let(:response_headers) { { 'Link' => '<http://unrelated-site.com>; rel="me"' } }
        let(:html) do
          <<~HTML
            <!doctype html>
            <body>
              <a href="#{link_back}" rel="me">Follow me on Mastodon</a>
            </body>
          HTML
        end

        it 'marks the field as verified' do
          expect(field.verified?).to be true
        end
      end

      context 'when the response is not successful' do
        let(:response_status) { 404 }
        let(:response_headers) { { 'Link' => "<#{link_back}>; rel=\"me\"" } }

        it 'does not mark the field as verified' do
          expect(field.verified?).to be false
        end
      end

      context 'when the header leaves the rel value unquoted' do
        let(:response_headers) { { 'Link' => "<#{link_back}>; rel=me" } }

        it 'marks the field as verified' do
          expect(field.verified?).to be true
        end
      end

      context 'when the header lists other parameters before rel' do
        let(:response_headers) { { 'Link' => "<#{link_back}>; type=\"text/html\"; rel=\"me\"" } }

        it 'marks the field as verified' do
          expect(field.verified?).to be true
        end
      end

      context 'when the header holds several comma-separated links and only the last links back' do
        let(:response_headers) { { 'Link' => "<http://unrelated-site.com>; rel=\"me\", <#{link_back}>; rel=\"me\"" } }

        it 'marks the field as verified' do
          expect(field.verified?).to be true
        end
      end

      context 'when the header rel lists me among other relation types' do
        let(:response_headers) { { 'Link' => "<#{link_back}>; rel=\"me nofollow\"" } }

        it 'marks the field as verified' do
          expect(field.verified?).to be true
        end
      end

      context 'when the header rel merely contains me as a substring' do
        let(:response_headers) { { 'Link' => "<#{link_back}>; rel=\"home\"" } }

        it 'does not mark the field as verified' do
          expect(field.verified?).to be false
        end
      end

      context 'when the header links back but the body is empty' do
        let(:html) { '' }
        let(:response_headers) { { 'Link' => "<#{link_back}>; rel=\"me\"" } }

        it 'marks the field as verified' do
          expect(field.verified?).to be true
        end
      end
    end
  end

  context 'when given a remote account' do
    let(:account) { Fabricate(:account, username: 'alice', domain: 'example.com', url: 'https://profile.example.com/alice') }
    let(:field)   { Account::Field.new(account, 'name' => 'Website', 'value' => '<a href="http://example.com" rel="me"><span class="invisible">http://</span><span class="">example.com</span><span class="invisible"></span></a>') }
    let(:response_headers) { {} }

    before do
      stub_request(:get, 'http://example.com').to_return(status: 200, body: html, headers: response_headers)
      subject.call(field)
    end

    context 'when the response carries a Link header with rel="me" back' do
      let(:response_headers) { { 'Link' => '<https://profile.example.com/alice>; rel="me"' } }
      let(:html) do
        <<~HTML
          <!doctype html>
          <body>
            <p>This page has no rel="me" links in its markup.</p>
          </body>
        HTML
      end

      it 'marks the field as verified' do
        expect(field.verified?).to be true
      end
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

  context 'when the same service instance verifies several fields' do
    let(:account)      { Fabricate(:account, username: 'alice') }
    let(:link_back)    { ActivityPub::TagManager.instance.url_for(account) }
    let(:first_field)  { Account::Field.new(account, 'name' => 'Website', 'value' => 'http://example.com') }
    let(:second_field) { Account::Field.new(account, 'name' => 'Blog', 'value' => 'http://unavailable.example') }
    let(:link_back_headers) { { 'Link' => "<#{link_back}>; rel=\"me\"" } }
    let(:html) do
      <<~HTML
        <!doctype html>
        <body>
          <a href="#{link_back}" rel="me">Follow me on Mastodon</a>
        </body>
      HTML
    end

    before do
      stub_request(:get, 'http://example.com').to_return(status: 200, body: html, headers: link_back_headers)
      stub_request(:get, 'http://unavailable.example').to_return(status: 404, body: html, headers: link_back_headers)

      subject.call(first_field)
      subject.call(second_field)
    end

    it 'does not carry a successful response over to a later unsuccessful one' do
      expect(first_field.verified?).to be true
      expect(second_field.verified?).to be false
    end
  end
end
