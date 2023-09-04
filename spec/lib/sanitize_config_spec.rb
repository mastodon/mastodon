# frozen_string_literal: true

require 'rails_helper'

describe Sanitize::Config do
  describe '::MASTODON_STRICT' do
    subject { Sanitize::Config::MASTODON_STRICT }

    it 'converts h1 to p' do
      expect(Sanitize.fragment('<h1>Foo</h1>', subject)).to eq '<p>Foo</p>'
    end

    it 'converts ul to p' do
      expect(Sanitize.fragment('<p>Check out:</p><ul><li>Foo</li><li>Bar</li></ul>', subject)).to eq '<p>Check out:</p><p>Foo<br>Bar</p>'
    end

    it 'converts p inside ul' do
      expect(Sanitize.fragment('<ul><li><p>Foo</p><p>Bar</p></li><li>Baz</li></ul>', subject)).to eq '<p>Foo<br>Bar<br>Baz</p>'
    end

    it 'converts ul inside ul' do
      expect(Sanitize.fragment('<ul><li>Foo</li><li><ul><li>Bar</li><li>Baz</li></ul></li></ul>', subject)).to eq '<p>Foo<br>Bar<br>Baz</p>'
    end

    it 'keep links in lists' do
      expect(Sanitize.fragment('<p>Check out:</p><ul><li><a href="https://joinmastodon.org" rel="nofollow noopener noreferrer" target="_blank">joinmastodon.org</a></li><li>Bar</li></ul>', subject)).to eq '<p>Check out:</p><p><a href="https://joinmastodon.org" rel="nofollow noopener noreferrer" target="_blank">joinmastodon.org</a><br>Bar</p>'
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
  end
end
