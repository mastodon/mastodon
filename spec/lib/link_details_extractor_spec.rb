# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LinkDetailsExtractor do
  subject { described_class.new(original_url, html, html_charset) }

  let(:original_url) { '' }
  let(:html) { '' }
  let(:html_charset) { nil }

  describe '#canonical_url' do
    let(:original_url) { 'https://foo.com/article?bar=baz123' }

    context 'when canonical URL points to another host' do
      let(:html) { '<!doctype html><link rel="canonical" href="https://bar.com/different-article" />' }

      it 'ignores the canonical URLs' do
        expect(subject.canonical_url).to eq original_url
      end
    end

    context 'when canonical URL points to the same host' do
      let(:html) { '<!doctype html><link rel="canonical" href="https://foo.com/article" />' }

      it 'ignores the canonical URLs' do
        expect(subject.canonical_url).to eq 'https://foo.com/article'
      end
    end

    context 'when canonical URL is set to "null"' do
      let(:html) { '<!doctype html><link rel="canonical" href="null" />' }

      it 'ignores the canonical URLs' do
        expect(subject.canonical_url).to eq original_url
      end
    end
  end

  context 'when structured data is present' do
    let(:original_url) { 'https://example.com/page.html' }

    context 'and is wrapped in CDATA tags' do
      let(:html) { <<~HTML }
        <!doctype html>
        <html>
        <head>
          <script type="application/ld+json">
          //<![CDATA[
          {"@context":"http://schema.org","@type":"NewsArticle","mainEntityOfPage":"https://example.com/page.html","headline":"Foo","datePublished":"2022-01-31T19:53:00+00:00","url":"https://example.com/page.html","description":"Bar","author":{"@type":"Person","name":"Hoge"},"publisher":{"@type":"Organization","name":"Baz"}}
          //]]>
          </script>
        </head>
        </html>
      HTML

      describe '#title' do
        it 'returns the title from structured data' do
          expect(subject.title).to eq 'Foo'
        end
      end

      describe '#description' do
        it 'returns the description from structured data' do
          expect(subject.description).to eq 'Bar'
        end
      end

      describe '#provider_name' do
        it 'returns the provider name from structured data' do
          expect(subject.provider_name).to eq 'Baz'
        end
      end

      describe '#author_name' do
        it 'returns the author name from structured data' do
          expect(subject.author_name).to eq 'Hoge'
        end
      end
    end

    context 'but the first tag is invalid JSON' do
      let(:html) { <<~HTML }
        <!doctype html>
        <html>
        <body>
          <script type="application/ld+json">
            {
              "@context":"https://schema.org",
              "@type":"ItemList",
              "url":"https://example.com/page.html",
              "name":"Foo",
              "description":"Bar"
            },
            {
              "@context": "https://schema.org",
              "@type": "BreadcrumbList",
              "itemListElement":[
                {
                  "@type":"ListItem",
                  "position":1,
                  "item":{
                    "@id":"https://www.example.com",
                    "name":"Baz"
                  }
                }
              ]
            }
          </script>
          <script type="application/ld+json">
            {
              "@context":"https://schema.org",
              "@type":"NewsArticle",
              "mainEntityOfPage": {
                "@type":"WebPage",
                "@id": "http://example.com/page.html"
              },
              "headline": "Foo",
              "description": "Bar",
              "datePublished": "2022-01-31T19:46:00+00:00",
              "author": {
                "@type": "Organization",
                "name": "Hoge"
              },
              "publisher": {
                "@type": "NewsMediaOrganization",
                "name":"Baz",
                "url":"https://example.com/"
              }
            }
          </script>
        </body>
        </html>
      HTML

      describe '#title' do
        it 'returns the title from structured data' do
          expect(subject.title).to eq 'Foo'
        end
      end

      describe '#description' do
        it 'returns the description from structured data' do
          expect(subject.description).to eq 'Bar'
        end
      end

      describe '#provider_name' do
        it 'returns the provider name from structured data' do
          expect(subject.provider_name).to eq 'Baz'
        end
      end

      describe '#author_name' do
        it 'returns the author name from structured data' do
          expect(subject.author_name).to eq 'Hoge'
        end
      end
    end
  end
end
