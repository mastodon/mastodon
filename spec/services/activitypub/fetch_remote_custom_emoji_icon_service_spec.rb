# frozen_string_literal: true

require 'rails_helper'

describe ActivityPub::FetchRemoteCustomEmojiIconService, type: :service do
  it 'uses prefetched_json if provided' do
    json = <<~JSON
      {
        "@context": "https://www.w3.org/ns/activitystreams",
        "id": "https://kickass.zone/emojis/1",
        "type": "Image",
        "url": "https://kickass.zone/system/custom_emoji_icons/images/emojo.png"
      }
    JSON

    stub_request(:get, 'https://kickass.zone/system/custom_emoji_icons/images/emojo.png').to_return body: attachment_fixture('emojo.png')

    result = ActivityPub::FetchRemoteCustomEmojiIconService.new.call(nil, json)

    expect(result.uri).to eq 'https://kickass.zone/emojis/1'
  end

  it 'fetches from remote if prefetched_json is not provided' do
    json = <<~JSON
      {
        "@context": "https://www.w3.org/ns/activitystreams",
        "id": "https://kickass.zone/emojis/1",
        "type": "Image",
        "url": "https://kickass.zone/system/custom_emoji_icons/images/emojo.png"
      }
    JSON

    stub_request(:get, 'https://kickass.zone/system/custom_emoji_icons/images/emojo.png').to_return body: attachment_fixture('emojo.png')
    stub_request(:get, 'https://kickass.zone/emojis/1').to_return headers: { 'Content-Type': 'application/activity+json' }, body: json

    result = ActivityPub::FetchRemoteCustomEmojiIconService.new.call('https://kickass.zone/emojis/1')

    expect(result.uri).to eq 'https://kickass.zone/emojis/1'
  end

  it 'returns nil unless the context is supported' do
    json = <<~JSON
      {
        "id": "https://kickass.zone/emojis/1",
        "type": "Image",
        "url": "https://kickass.zone/system/custom_emoji_icons/images/emojo.png"
      }
    JSON

    stub_request(:get, 'https://kickass.zone/system/custom_emoji_icons/images/emojo.png').to_return body: attachment_fixture('emojo.png')

    result = ActivityPub::FetchRemoteCustomEmojiIconService.new.call(nil, json)

    expect(result).to eq nil
  end

  it 'returns nil unless the type is Image' do
    json = <<~JSON
      {
        "@context": "https://www.w3.org/ns/activitystreams",
        "id": "https://kickass.zone/emojis/1",
        "url": "https://kickass.zone/system/custom_emoji_icons/images/emojo.png"
      }
    JSON

    stub_request(:get, 'https://kickass.zone/system/custom_emoji_icons/images/emojo.png').to_return body: attachment_fixture('emojo.png')

    result = ActivityPub::FetchRemoteCustomEmojiIconService.new.call(nil, json)

    expect(result).to eq nil
  end

  it 'returns nil if it failed to save' do
    json = <<~JSON
      {
        "@context": "https://www.w3.org/ns/activitystreams",
        "id": "https://kickass.zone/emojis/1",
        "type": "Image",
        "url": "https://kickass.zone/system/custom_emoji_icons/images/emojo.png"
      }
    JSON

    stub_request(:get, 'https://kickass.zone/system/custom_emoji_icons/images/emojo.png').to_return status: 400
    result = ActivityPub::FetchRemoteCustomEmojiIconService.new.call(nil, json)

    expect(result).to eq nil
  end
end
