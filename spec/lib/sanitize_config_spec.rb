# frozen_string_literal: true

require 'rails_helper'

describe Sanitize::Config do
  shared_examples 'common HTML sanitization' do
    it 'converts h1 to p strong' do
      expect(Sanitize.fragment('<h1>Foo</h1>', subject)).to eq '<p><strong>Foo</strong></p>'
    end

    it 'keeps ul' do
      expect(Sanitize.fragment('<p>Check out:</p><ul><li>Foo</li><li>Bar</li></ul>', subject)).to eq '<p>Check out:</p><ul><li>Foo</li><li>Bar</li></ul>'
    end

    it 'keeps start and reversed attributes of ol' do
      expect(Sanitize.fragment('<p>Check out:</p><ol start="3" reversed=""><li>Foo</li><li>Bar</li></ol>', subject)).to eq '<p>Check out:</p><ol start="3" reversed=""><li>Foo</li><li>Bar</li></ol>'
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

    it 'does not re-interpret HTML when removing unsupported links' do
      expect(Sanitize.fragment('<a href="foo://bar">Test&lt;a href="https://example.com"&gt;test&lt;/a&gt;</a>', subject)).to eq 'Test&lt;a href="https://example.com"&gt;test&lt;/a&gt;'
    end

    it 'keeps a with href' do
      expect(Sanitize.fragment('<a href="http://example.com">Test</a>', subject)).to eq '<a href="http://example.com" rel="nofollow noopener noreferrer" target="_blank">Test</a>'
    end

    it 'removes a with unparsable href' do
      expect(Sanitize.fragment('<a href=" https://google.fr">Test</a>', subject)).to eq 'Test'
    end

    it 'keeps a with supported scheme and no host' do
      expect(Sanitize.fragment('<a href="dweb:/a/foo">Test</a>', subject)).to eq '<a href="dweb:/a/foo" rel="nofollow noopener noreferrer" target="_blank">Test</a>'
    end
  end

  describe '::MASTODON_STRICT' do
    subject { Sanitize::Config::MASTODON_STRICT }

    it_behaves_like 'common HTML sanitization'
  end

  describe '::MASTODON_OUTGOING' do
    subject { Sanitize::Config::MASTODON_OUTGOING }

    around do |example|
      original_web_domain = Rails.configuration.x.web_domain
      example.run
      Rails.configuration.x.web_domain = original_web_domain
    end

    it_behaves_like 'common HTML sanitization'

    it 'keeps a with href and rel tag, not adding to rel or target if url is local' do
      Rails.configuration.x.web_domain = 'domain.test'
      expect(Sanitize.fragment('<a href="http://domain.test/tags/foo" rel="tag">Test</a>', subject)).to eq '<a href="http://domain.test/tags/foo" rel="tag">Test</a>'
    end
  end
end
