# frozen_string_literal: true

require 'rails_helper'
require Rails.root.join('app', 'lib', 'sanitize_config.rb')

describe Sanitize::Config do
  describe '::MASTODON_STRICT' do
    subject { Sanitize::Config::MASTODON_STRICT }

    around do |example|
      original_web_domain = Rails.configuration.x.web_domain
      example.run
      Rails.configuration.x.web_domain = original_web_domain
    end

    it 'keeps h1' do
      expect(Sanitize.fragment('<h1>Foo</h1>', subject)).to eq '<h1>Foo</h1>'
    end

    it 'keeps ul' do
      expect(Sanitize.fragment('<p>Check out:</p><ul><li>Foo</li><li>Bar</li></ul>', subject)).to eq '<p>Check out:</p><ul><li>Foo</li><li>Bar</li></ul>'
    end

    it 'removes a without href' do
      expect(Sanitize.fragment('<a>Test</a>', subject)).to eq 'Test'
    end

    it 'removes a without href and only keeps text content' do
      expect(Sanitize.fragment('<a><span class="invisible">foo&amp;</span><span>Test</span></a>', subject)).to eq 'foo&amp;Test'
    end

    it 'removes a with unsupported scheme in href' do
      expect(Sanitize.fragment('<a href="foo://bar">Test</a>', subject)).to eq 'Test'
    end

    it 'keeps a with href' do
      expect(Sanitize.fragment('<a href="http://example.com">Test</a>', subject)).to eq '<a href="http://example.com" rel="nofollow noopener noreferrer" target="_blank">Test</a>'
    end

    it 'keeps a with href and rel tag' do
      expect(Sanitize.fragment('<a href="http://example.com" rel="tag">Test</a>', subject)).to eq '<a href="http://example.com" rel="tag nofollow noopener noreferrer" target="_blank">Test</a>'
    end

    it 'keeps a with href and rel tag, not adding to rel if url is local' do
      Rails.configuration.x.web_domain = 'domain.test'
      expect(Sanitize.fragment('<a href="http://domain.test/tags/foo" rel="tag">Test</a>', subject.merge(outgoing: true))).to eq '<a href="http://domain.test/tags/foo" rel="tag" target="_blank">Test</a>'
    end
  end
end
