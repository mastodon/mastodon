require 'spec_helper'
require 'active_support/core_ext/string'
require 'uri'
require 'rack/utils'
require 'doorkeeper/oauth/authorization/uri_builder'

module Doorkeeper::OAuth::Authorization
  describe URIBuilder do
    subject { URIBuilder }

    describe :uri_with_query do
      it 'returns the uri with query' do
        uri = subject.uri_with_query 'http://example.com/', parameter: 'value'
        expect(uri).to eq('http://example.com/?parameter=value')
      end

      it 'rejects nil values' do
        uri = subject.uri_with_query 'http://example.com/', parameter: ''
        expect(uri).to eq('http://example.com/?')
      end

      it 'preserves original query parameters' do
        uri = subject.uri_with_query 'http://example.com/?query1=value', parameter: 'value'
        expect(uri).to match(/query1=value/)
        expect(uri).to match(/parameter=value/)
      end
    end

    describe :uri_with_fragment do
      it 'returns uri with parameters as fragments' do
        uri = subject.uri_with_fragment 'http://example.com/', parameter: 'value'
        expect(uri).to eq('http://example.com/#parameter=value')
      end

      it 'preserves original query parameters' do
        uri = subject.uri_with_fragment 'http://example.com/?query1=value1', parameter: 'value'
        expect(uri).to eq('http://example.com/?query1=value1#parameter=value')
      end
    end
  end
end
