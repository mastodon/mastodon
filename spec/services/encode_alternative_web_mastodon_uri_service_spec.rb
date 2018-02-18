# frozen_string_literal: true

require 'rails_helper'

describe EncodeAlternativeWebMastodonURIService do
  it 'returns nil for follow authorization with web parameter' do
    expect(EncodeAlternativeWebMastodonURIService.new.call('authorize_follows', 'acct' => 'username@example.com', 'web' => 'true')).to eq nil
  end

  it 'returns web+mastodon URI for follow authorization with prefixed acct query' do
    expect(EncodeAlternativeWebMastodonURIService.new.call('authorize_follows', 'acct' => 'acct:username@example.com')).to eq Addressable::URI.parse('web+mastodon://follow?uri=acct:username@example.com')
  end

  it 'returns web+mastodon URI for follow authorization with unprefixed acct query' do
    expect(EncodeAlternativeWebMastodonURIService.new.call('authorize_follows', 'acct' => 'username@example.com')).to eq Addressable::URI.parse('web+mastodon://follow?uri=acct:username@example.com')
  end

  it 'returns nil for share with web parameter' do
    expect(EncodeAlternativeWebMastodonURIService.new.call('authorize_follows', 'acct' => 'username@example.com', 'web' => 'true')).to eq nil
  end
  it 'returns web+mastodon URI for share with text query' do
    expect(EncodeAlternativeWebMastodonURIService.new.call('shares', 'text' => 'Text.')).to eq Addressable::URI.parse('web+mastodon://share?text=Text.')
  end
end
