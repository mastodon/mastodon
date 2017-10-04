# frozen_string_literal: true

require 'rails_helper'

describe FetchRemoteCustomEmojiIconService, type: :service do
  context 'when protocol is ostatus' do
    it 'creates an icon' do
      stub_request(:get, 'https://kickass.zone/system/custom_emoji_icons/images/emojo.png').to_return body: attachment_fixture('emojo.png')

      result = FetchRemoteCustomEmojiIconService.new.call(nil, <<~XML)
        <?xml version="1.0"?>
        <entry xmlns="http://www.w3.org/2005/Atom">
          <id>https://kickass.zone/emojis/1</id>
          <link href="https://kickass.zone/system/custom_emoji_icons/images/emojo.png" rel="enclosure"/>
        </entry>
      XML

      expect(result.uri).to eq 'https://kickass.zone/emojis/1'
    end

    it 'returns nil if it failed to save' do
      stub_request(:get, 'https://kickass.zone/system/custom_emoji_icons/images/emojo.png').to_return status: 400

      result = FetchRemoteCustomEmojiIconService.new.call(nil, <<~XML)
        <?xml version="1.0"?>
        <entry xmlns="http://www.w3.org/2005/Atom">
          <id>https://kickass.zone/emojis/1</id>
          <link href="https://kickass.zone/system/custom_emoji_icons/images/emojo.png" rel="enclosure"/>
        </entry>
      XML

      expect(result).to eq nil
    end
  end

  it 'uses prefetched_body if provided' do
    stub_request(:get, 'https://kickass.zone/system/custom_emoji_icons/images/emojo.png').to_return body: attachment_fixture('emojo.png')
    result = FetchRemoteCustomEmojiIconService.new.call(nil, <<~XML)
      <?xml version="1.0"?>
      <entry xmlns="http://www.w3.org/2005/Atom">
        <id>https://kickass.zone/emojis/1</id>
        <link href="https://kickass.zone/system/custom_emoji_icons/images/emojo.png" rel="enclosure"/>
      </entry>
    XML

    expect(result.uri).to eq 'https://kickass.zone/emojis/1'
    expect(result.image_remote_url).to eq 'https://kickass.zone/system/custom_emoji_icons/images/emojo.png'
  end

  it 'fetches from remote if prefetched_body is not provided' do
    stub_request(:get, 'https://kickass.zone/system/custom_emoji_icons/images/emojo.png').to_return body: attachment_fixture('emojo.png')
    stub_request(:get, 'https://kickass.zone/emojis/1').to_return headers: { 'Content-Type': 'application/activity+json' }, body: <<-JSON
      {
        "@context": "https://www.w3.org/ns/activitystreams",
        "id": "https://kickass.zone/emojis/1",
        "type": "Image",
        "url": "https://kickass.zone/system/custom_emoji_icons/images/emojo.png"
      }
    JSON

    result = FetchRemoteCustomEmojiIconService.new.call('https://kickass.zone/emojis/1')

    expect(result.uri).to eq 'https://kickass.zone/emojis/1'
    expect(result.image_remote_url).to eq 'https://kickass.zone/system/custom_emoji_icons/images/emojo.png'
  end
end
