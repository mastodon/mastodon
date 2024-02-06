# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LinkDetailsExtractor do
  subject { described_class.new(original_url, html, nil) }

  let(:original_url) { 'https://example.com/dog.html?tracking=123' }

  describe '#canonical_url' do
    let(:html) { "<!doctype html><link rel='canonical' href='#{url}'>" }

    context 'when canonical URL points to the same host' do
      let(:url) { 'https://example.com/dog.html' }

      it 'ignores the canonical URLs' do
        expect(subject.canonical_url).to eq 'https://example.com/dog.html'
      end
    end

    context 'when canonical URL points to another host' do
      let(:url) { 'https://different.example.net/dog.html' }

      it 'ignores the canonical URLs' do
        expect(subject.canonical_url).to eq original_url
      end
    end

    context 'when canonical URL is set to "null"' do
      let(:url) { 'null' }

      it 'ignores the canonical URLs' do
        expect(subject.canonical_url).to eq original_url
      end
    end
  end

  context 'when only basic metadata is present' do
    let(:html) { <<~HTML }
      <!doctype html>
      <html lang="en">
      <head>
        <title>Man bites dog</title>
        <meta name="description" content="A dog&#39;s tale">
      </head>
      </html>
    HTML

    describe '#title' do
      it 'returns the title from title tag' do
        expect(subject.title).to eq 'Man bites dog'
      end
    end

    describe '#description' do
      it 'returns the description from meta tag' do
        expect(subject.description).to eq "A dog's tale"
      end
    end

    describe '#language' do
      it 'returns the language from lang attribute' do
        expect(subject.language).to eq 'en'
      end
    end
  end

  context 'when structured data is present' do
    let(:ld_json) do
      {
        '@context' => 'https://schema.org',
        '@type' => 'NewsArticle',
        'headline' => 'Man bites dog',
        'description' => "A dog's tale",
        'datePublished' => '2022-01-31T19:53:00+00:00',
        'author' => {
          '@type' => 'Organization',
          'name' => 'Charlie Brown',
        },
        'publisher' => {
          '@type' => 'NewsMediaOrganization',
          'name' => 'Pet News',
          'url' => 'https://example.com',
        },
      }.to_json
    end

    shared_examples 'structured data' do
      describe '#title' do
        it 'returns the title from structured data' do
          expect(subject.title).to eq 'Man bites dog'
        end
      end

      describe '#description' do
        it 'returns the description from structured data' do
          expect(subject.description).to eq "A dog's tale"
        end
      end

      describe '#published_at' do
        it 'returns the publicaton time from structured data' do
          expect(subject.published_at).to eq '2022-01-31T19:53:00+00:00'
        end
      end

      describe '#author_name' do
        it 'returns the author name from structured data' do
          expect(subject.author_name).to eq 'Charlie Brown'
        end
      end

      describe '#provider_name' do
        it 'returns the provider name from structured data' do
          expect(subject.provider_name).to eq 'Pet News'
        end
      end
    end

    context 'when is wrapped in CDATA tags' do
      let(:html) { <<~HTML }
        <!doctype html>
        <html>
          <head>
            <script type="application/ld+json">
              //<![CDATA[
              #{ld_json}
              //]]>
            </script>
          </head>
        </html>
      HTML

      include_examples 'structured data'
    end

    context 'with the first tag is invalid JSON' do
      let(:html) { <<~HTML }
        <!doctype html>
        <html>
        <body>
          <script type="application/ld+json">
            invalid LD+JSON
          </script>
          <script type="application/ld+json">
            #{ld_json}
          </script>
        </body>
        </html>
      HTML

      include_examples 'structured data'
    end

    context 'with preceding block of unsupported LD+JSON' do
      let(:html) { <<~HTML }
        <!doctype html>
        <html>
        <body>
          <script type="application/ld+json">
            [
              {
                "@context": "https://schema.org",
                "@type": "ItemList",
                "url": "https://example.com/cat.html",
                "name": "Man bites cat",
                "description": "A cat's tale"
              },
              {
                "@context": "https://schema.org",
                "@type": "BreadcrumbList",
                "itemListElement":[
                  {
                    "@type": "ListItem",
                    "position": 1,
                    "item": {
                      "@id": "https://www.example.com",
                      "name": "Cat News"
                    }
                  }
                ]
              }
            ]
          </script>
          <script type="application/ld+json">
            #{ld_json}
          </script>
        </body>
        </html>
      HTML

      include_examples 'structured data'
    end

    context 'with unsupported in same block LD+JSON' do
      let(:html) { <<~HTML }
        <!doctype html>
        <html>
        <body>
          <script type="application/ld+json">
            [
              {
                "@context": "https://schema.org",
                "@type": "ItemList",
                "url": "https://example.com/cat.html",
                "name": "Man bites cat",
                "description": "A cat's tale"
              },
              #{ld_json}
            ]
          </script>
        </body>
        </html>
      HTML

      include_examples 'structured data'
    end
  end

  context 'when Open Graph protocol data is present' do
    let(:html) { <<~HTML }
      <!doctype html>
      <html>
      <head>
        <meta property="og:url" content="https://example.com/dog.html">
        <meta property="og:title" content="Man bites dog">
        <meta property="og:description" content="A dog's tale">
        <meta property="article:published_time" content="2022-01-31T19:53:00+00:00">
        <meta property="og:author" content="Charlie Brown">
        <meta property="og:locale" content="en">
        <meta property="og:image" content="https://example.com/snoopy.jpg">
        <meta property="og:image:alt" content="A good boy">
        <meta property="og:site_name" content="Pet News">
      </head>
      </html>
    HTML

    describe '#canonical_url' do
      it 'returns the URL from Open Graph protocol data' do
        expect(subject.canonical_url).to eq 'https://example.com/dog.html'
      end
    end

    describe '#title' do
      it 'returns the title from Open Graph protocol data' do
        expect(subject.title).to eq 'Man bites dog'
      end
    end

    describe '#description' do
      it 'returns the description from Open Graph protocol data' do
        expect(subject.description).to eq "A dog's tale"
      end
    end

    describe '#published_at' do
      it 'returns the publicaton time from Open Graph protocol data' do
        expect(subject.published_at).to eq '2022-01-31T19:53:00+00:00'
      end
    end

    describe '#author_name' do
      it 'returns the author name from Open Graph protocol data' do
        expect(subject.author_name).to eq 'Charlie Brown'
      end
    end

    describe '#language' do
      it 'returns the language from Open Graph protocol data' do
        expect(subject.language).to eq 'en'
      end
    end

    describe '#image' do
      it 'returns the image from Open Graph protocol data' do
        expect(subject.image).to eq 'https://example.com/snoopy.jpg'
      end
    end

    describe '#image:alt' do
      it 'returns the image description from Open Graph protocol data' do
        expect(subject.image_alt).to eq 'A good boy'
      end
    end

    describe '#provider_name' do
      it 'returns the provider name from Open Graph protocol data' do
        expect(subject.provider_name).to eq 'Pet News'
      end
    end
  end
end
