# frozen_string_literal: true

require 'rails_helper'

describe HttpHelper do
  describe 'http_client' do
    it 'returns HTTP::Client with default options' do
      options = helper.http_client.default_options
      expect(options.headers['User-Agent']).to match /.+ \(Mastodon\/.+;\ \+http:\/\/cb6e6126\.ngrok\.io\/\)/
      expect(options.timeout_options).to eq read_timeout: 10, write_timeout: 10, connect_timeout: 10
    end
  end
end
