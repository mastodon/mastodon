# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Username URL rewrites' do
  describe 'GET /users/:username' do
    it 'redirects to at-username page variation' do
      get '/users/username'

      expect(response)
        .to have_http_status(301)
        .and redirect_to('/@username')
      expect(response.headers)
        .to include('Vary' => 'Origin, Accept')
    end
  end

  describe 'GET /users/:username/following' do
    it 'redirects to at-username page variation' do
      get '/users/username/following'

      expect(response)
        .to have_http_status(301)
        .and redirect_to('/@username/following')
      expect(response.headers)
        .to include('Vary' => 'Origin, Accept')
    end
  end

  describe 'GET /users/:username/followers' do
    it 'redirects to at-username page variation' do
      get '/users/username/followers'

      expect(response)
        .to have_http_status(301)
        .and redirect_to('/@username/followers')
      expect(response.headers)
        .to include('Vary' => 'Origin, Accept')
    end
  end

  describe 'GET /users/:username/statuses/:id' do
    it 'redirects to at-username page variation' do
      get '/users/username/statuses/123456'

      expect(response)
        .to have_http_status(301)
        .and redirect_to('/@username/123456')
      expect(response.headers)
        .to include('Vary' => 'Origin, Accept')
    end
  end
end
