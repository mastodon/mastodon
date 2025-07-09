# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::Parser::MediaAttachmentParser do
  subject { described_class.new(json) }

  let(:json) do
    {
      '@context': 'https://www.w3.org/ns/activitystreams',
      type: 'Document',
      mediaType: 'image/png',
      url: 'http://example.com/attachment.png',
    }.deep_stringify_keys
  end

  it 'correctly parses media attachment' do
    expect(subject).to have_attributes(
      remote_url: 'http://example.com/attachment.png',
      file_content_type: 'image/png'
    )
  end

  context 'when the URL is a link with multiple options' do
    let(:json) do
      {
        '@context': 'https://www.w3.org/ns/activitystreams',
        type: 'Document',
        url: [
          {
            type: 'Link',
            mediaType: 'image/png',
            href: 'http://example.com/attachment.png',
          },
          {
            type: 'Link',
            mediaType: 'image/avif',
            href: 'http://example.com/attachment.avif',
          },
        ],
      }.deep_stringify_keys
    end

    it 'returns the first option' do
      expect(subject).to have_attributes(
        remote_url: 'http://example.com/attachment.png',
        file_content_type: 'image/png'
      )
    end
  end
end
