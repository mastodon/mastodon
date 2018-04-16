require 'spec_helper'
require 'uri'
require 'doorkeeper/oauth/helpers/uri_checker'

module Doorkeeper::OAuth::Helpers
  describe URIChecker do
    describe '.valid?' do
      it 'is valid for valid uris' do
        uri = 'http://app.co'
        expect(URIChecker.valid?(uri)).to be_truthy
      end

      it 'is valid if include path param' do
        uri = 'http://app.co/path'
        expect(URIChecker.valid?(uri)).to be_truthy
      end

      it 'is valid if include query param' do
        uri = 'http://app.co/?query=1'
        expect(URIChecker.valid?(uri)).to be_truthy
      end

      it 'is invalid if uri includes fragment' do
        uri = 'http://app.co/test#fragment'
        expect(URIChecker.valid?(uri)).to be_falsey
      end

      it 'is invalid if scheme is missing' do
        uri = 'app.co'
        expect(URIChecker.valid?(uri)).to be_falsey
      end

      it 'is invalid if is a relative uri' do
        uri = '/abc/123'
        expect(URIChecker.valid?(uri)).to be_falsey
      end

      it 'is invalid if is not a url' do
        uri = 'http://'
        expect(URIChecker.valid?(uri)).to be_falsey
      end

      it 'is invalid if is not an uri' do
        uri = '   '
        expect(URIChecker.valid?(uri)).to be_falsey
      end
    end

    describe '.matches?' do
      it 'is true if both url matches' do
        uri = client_uri = 'http://app.co/aaa'
        expect(URIChecker.matches?(uri, client_uri)).to be_truthy
      end

      it 'ignores query parameter on comparsion' do
        uri = 'http://app.co/?query=hello'
        client_uri = 'http://app.co'
        expect(URIChecker.matches?(uri, client_uri)).to be_truthy
      end

      it 'doesn\'t allow non-matching domains through' do
        uri = 'http://app.abc/?query=hello'
        client_uri = 'http://app.co'
        expect(URIChecker.matches?(uri, client_uri)).to be_falsey
      end

      it 'doesn\'t allow non-matching domains that don\'t start at the beginning' do
        uri = 'http://app.co/?query=hello'
        client_uri = 'http://example.com?app.co=test'
        expect(URIChecker.matches?(uri, client_uri)).to be_falsey
      end

      context "client registered query params" do
        it "doesn't allow query being absent" do
          uri = 'http://app.co'
          client_uri = 'http://app.co/?vendorId=AJ4L7XXW9'
          expect(URIChecker.matches?(uri, client_uri)).to be_falsey
        end

        it "is false if query values differ but key same" do
          uri = 'http://app.co/?vendorId=pancakes'
          client_uri = 'http://app.co/?vendorId=waffles'
          expect(URIChecker.matches?(uri, client_uri)).to be_falsey
        end

        it "is false if query values same but key differs" do
          uri = 'http://app.co/?foo=pancakes'
          client_uri = 'http://app.co/?bar=pancakes'
          expect(URIChecker.matches?(uri, client_uri)).to be_falsey
        end

        it "is false if query present and match, but unknown queries present" do
          uri = 'http://app.co/?vendorId=pancakes&unknown=query'
          client_uri = 'http://app.co/?vendorId=waffles'
          expect(URIChecker.matches?(uri, client_uri)).to be_falsey
        end

        it "is true if queries are present and matche" do
          uri = 'http://app.co/?vendorId=AJ4L7XXW9&foo=bar'
          client_uri = 'http://app.co/?vendorId=AJ4L7XXW9&foo=bar'
          expect(URIChecker.matches?(uri, client_uri)).to be_truthy
        end

        it "is true if queries are present, match and in different order" do
          uri = 'http://app.co/?bing=bang&foo=bar'
          client_uri = 'http://app.co/?foo=bar&bing=bang'
          expect(URIChecker.matches?(uri, client_uri)).to be_truthy
        end
      end
    end

    describe '.valid_for_authorization?' do
      it 'is true if valid and matches' do
        uri = client_uri = 'http://app.co/aaa'
        expect(URIChecker.valid_for_authorization?(uri, client_uri)).to be_truthy
      end

      it 'is false if valid and mismatches' do
        uri = 'http://app.co/aaa'
        client_uri = 'http://app.co/bbb'
        expect(URIChecker.valid_for_authorization?(uri, client_uri)).to be_falsey
      end

      it 'is true if valid and included in array' do
        uri = 'http://app.co/aaa'
        client_uri = "http://example.com/bbb\nhttp://app.co/aaa"
        expect(URIChecker.valid_for_authorization?(uri, client_uri)).to be_truthy
      end

      it 'is false if valid and not included in array' do
        uri = 'http://app.co/aaa'
        client_uri = "http://example.com/bbb\nhttp://app.co/cc"
        expect(URIChecker.valid_for_authorization?(uri, client_uri)).to be_falsey
      end

      it 'is true if valid and matches' do
        uri = client_uri = 'http://app.co/aaa'
        expect(URIChecker.valid_for_authorization?(uri, client_uri)).to be true
      end

      it 'is false if invalid' do
        uri = 'http://app.co/aaa?pankcakes=abc'
        client_uri = 'http://app.co/aaa?waffles=abc'
        expect(URIChecker.valid_for_authorization?(uri, client_uri)).to be false
      end

      it 'calls .matches?' do
        uri = 'http://app.co/aaa?pankcakes=abc'
        client_uri = 'http://app.co/aaa?waffles=abc'
        expect(URIChecker).to receive(:matches?).with(uri, client_uri).once
        URIChecker.valid_for_authorization?(uri, client_uri)
      end

      it 'calls .valid?' do
        uri = 'http://app.co/aaa?pankcakes=abc'
        client_uri = 'http://app.co/aaa?waffles=abc'
        expect(URIChecker).to receive(:valid?).with(uri).once
        URIChecker.valid_for_authorization?(uri, client_uri)
      end
    end

    describe '.query_matches?' do
      it 'is true if no queries' do
        expect(URIChecker.query_matches?('', '')).to be_truthy
        expect(URIChecker.query_matches?(nil, nil)).to be_truthy
      end

      it 'is true if same query' do
        expect(URIChecker.query_matches?('foo', 'foo')).to be_truthy
      end

      it 'is false if different query' do
        expect(URIChecker.query_matches?('foo', 'bar')).to be_falsey
      end

      it 'is true if same queries' do
        expect(URIChecker.query_matches?('foo&bar', 'foo&bar')).to be_truthy
      end

      it 'is true if same queries, different order' do
        expect(URIChecker.query_matches?('foo&bar', 'bar&foo')).to be_truthy
      end

      it 'is false if one different query' do
        expect(URIChecker.query_matches?('foo&bang', 'foo&bing')).to be_falsey
      end

      it 'is true if same query with same value' do
        expect(URIChecker.query_matches?('foo=bar', 'foo=bar')).to be_truthy
      end

      it 'is true if same queries with same values' do
        expect(URIChecker.query_matches?('foo=bar&bing=bang', 'foo=bar&bing=bang')).to be_truthy
      end

      it 'is true if same queries with same values, different order' do
        expect(URIChecker.query_matches?('foo=bar&bing=bang', 'bing=bang&foo=bar')).to be_truthy
      end

      it 'is false if same query with different value' do
        expect(URIChecker.query_matches?('foo=bar', 'foo=bang')).to be_falsey
      end

      it 'is false if some queries missing' do
        expect(URIChecker.query_matches?('foo=bar', 'foo=bar&bing=bang')).to be_falsey
      end

      it 'is false if some queries different value' do
        expect(URIChecker.query_matches?('foo=bar&bing=bang', 'foo=bar&bing=banana')).to be_falsey
      end
    end
  end
end
