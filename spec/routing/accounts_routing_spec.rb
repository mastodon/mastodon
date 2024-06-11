# frozen_string_literal: true

require 'rails_helper'

describe 'Routes under accounts/' do
  context 'with local username' do
    let(:username) { 'alice' }

    it 'routes /@:username' do
      expect(get("/@#{username}")).to route_to('accounts#show', username: username)
    end

    it 'routes /@:username.json' do
      expect(get("/@#{username}.json")).to route_to('accounts#show', username: username, format: 'json')
    end

    it 'routes /@:username.rss' do
      expect(get("/@#{username}.rss")).to route_to('accounts#show', username: username, format: 'rss')
    end

    it 'routes /@:username/:id' do
      expect(get("/@#{username}/123")).to route_to('statuses#show', account_username: username, id: '123')
    end

    it 'routes /@:username/:id/embed' do
      expect(get("/@#{username}/123/embed")).to route_to('statuses#embed', account_username: username, id: '123')
    end

    it 'routes /@:username/following' do
      expect(get("/@#{username}/following")).to route_to('following_accounts#index', account_username: username)
    end

    it 'routes /@:username/followers' do
      expect(get("/@#{username}/followers")).to route_to('follower_accounts#index', account_username: username)
    end

    it 'routes /@:username/with_replies' do
      expect(get("/@#{username}/with_replies")).to route_to('accounts#show', username: username)
    end

    it 'routes /@:username/media' do
      expect(get("/@#{username}/media")).to route_to('accounts#show', username: username)
    end

    it 'routes /@:username/tagged/:tag' do
      expect(get("/@#{username}/tagged/foo")).to route_to('accounts#show', username: username, tag: 'foo')
    end
  end

  context 'with remote username' do
    let(:username) { 'alice@example.com' }

    it 'routes /@:username' do
      expect(get("/@#{username}")).to route_to('home#index', username_with_domain: username)
    end

    it 'routes /@:username/:id' do
      expect(get("/@#{username}/123")).to route_to('home#index', username_with_domain: username, any: '123')
    end

    it 'routes /@:username/:id/embed' do
      expect(get("/@#{username}/123/embed")).to route_to('home#index', username_with_domain: username, any: '123/embed')
    end

    it 'routes /@:username/following' do
      expect(get("/@#{username}/following")).to route_to('home#index', username_with_domain: username, any: 'following')
    end

    it 'routes /@:username/followers' do
      expect(get("/@#{username}/followers")).to route_to('home#index', username_with_domain: username, any: 'followers')
    end

    it 'routes /@:username/with_replies' do
      expect(get("/@#{username}/with_replies")).to route_to('home#index', username_with_domain: username, any: 'with_replies')
    end

    it 'routes /@:username/media' do
      expect(get("/@#{username}/media")).to route_to('home#index', username_with_domain: username, any: 'media')
    end

    it 'routes /@:username/tagged/:tag' do
      expect(get("/@#{username}/tagged/foo")).to route_to('home#index', username_with_domain: username, any: 'tagged/foo')
    end
  end
end
