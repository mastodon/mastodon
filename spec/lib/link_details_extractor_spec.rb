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

    it 'extracts the expected values from html metadata' do
      expect(subject)
        .to have_attributes(
          title: eq('Man bites dog'),
          description: eq("A dog's tale"),
          language: eq('en')
        )
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
        'inLanguage' => {
          name: 'English',
          alternateName: 'en',
        },
      }.to_json
    end

    shared_examples 'structured data' do
      it 'extracts the expected values from structured data' do
        expect(subject)
          .to have_attributes(
            title: eq('Man bites dog'),
            description: eq("A dog's tale"),
            published_at: eq('2022-01-31T19:53:00+00:00'),
            author_name: eq('Charlie Brown'),
            provider_name: eq('Pet News'),
            language: eq('en')
          )
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

    context 'with the first tag is null' do
      let(:html) { <<~HTML }
        <!doctype html>
        <html>
        <body>
          <script type="application/ld+json">
            null
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

    context 'with author names as array' do
      let(:ld_json) do
        {
          '@context' => 'https://schema.org',
          '@type' => 'NewsArticle',
          'headline' => 'A lot of authors',
          'description' => 'But we decided to cram them into one',
          'author' => {
            '@type' => 'Person',
            'name' => ['Author 1', 'Author 2'],
          },
        }.to_json
      end
      let(:html) { <<~HTML }
        <!doctype html>
        <html>
        <body>
          <script type="application/ld+json">
            #{ld_json}
          </script>
        </body>
        </html>
      HTML

      it 'joins author names' do
        expect(subject.author_name).to eq 'Author 1, Author 2'
      end
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

    it 'extracts the expected values from open graph data' do
      expect(subject)
        .to have_attributes(
          canonical_url: eq('https://example.com/dog.html'),
          title: eq('Man bites dog'),
          description: eq("A dog's tale"),
          published_at: eq('2022-01-31T19:53:00+00:00'),
          author_name: eq('Charlie Brown'),
          language: eq('en'),
          image: eq('https://example.com/snoopy.jpg'),
          image_alt: eq('A good boy'),
          provider_name: eq('Pet News')
        )
    end
  end
end
