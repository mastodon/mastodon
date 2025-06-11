# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TextFormatter do
  describe '#to_s' do
    subject { described_class.new(text, preloaded_accounts: preloaded_accounts).to_s }

    let(:preloaded_accounts) { nil }

    context 'when given text containing plain text' do
      let(:text) { 'text' }

      it 'paragraphizes the text' do
        expect(subject).to eq '<p>text</p>'
      end
    end

    context 'when given text containing line feeds' do
      let(:text) { "line\nfeed" }

      it 'removes line feeds' do
        expect(subject).to_not include "\n"
      end
    end

    context 'when given text containing linkable mentions' do
      let(:preloaded_accounts) { [Fabricate(:account, username: 'alice')] }
      let(:text) { '@alice' }

      it 'creates a mention link' do
        expect(subject)
          .to include(<<~LINK.squish)
            <a href="https://#{Rails.configuration.x.local_domain}/@alice" class="u-url mention">@<span>alice</span></a>
          LINK
      end
    end

    context 'when given text containing unlinkable mentions' do
      let(:preloaded_accounts) { [] }
      let(:text) { '@alice' }

      it 'does not create a mention link' do
        expect(subject).to include '@alice'
      end
    end

    context 'when given a stand-alone medium URL' do
      let(:text) { 'https://hackernoon.com/the-power-to-build-communities-a-response-to-mark-zuckerberg-3f2cac9148a4' }

      it 'matches the full URL' do
        expect(subject).to include 'href="https://hackernoon.com/the-power-to-build-communities-a-response-to-mark-zuckerberg-3f2cac9148a4"'
      end
    end

    context 'when given a stand-alone Google URL' do
      let(:text) { 'http://google.com' }

      it 'matches the full URL' do
        expect(subject).to include 'href="http://google.com"'
      end
    end

    context 'when given a stand-alone URL with a newer TLD' do
      let(:text) { 'http://example.gay' }

      it 'matches the full URL' do
        expect(subject).to include 'href="http://example.gay"'
      end
    end

    context 'when given a stand-alone IDN URL' do
      let(:text) { 'https://nic.みんな/' }

      it 'matches the full URL' do
        expect(subject).to include 'href="https://nic.みんな/"'
      end

      it 'has display URL' do
        expect(subject).to include '<span class="">nic.みんな/</span>'
      end
    end

    context 'when given a URL with a trailing period' do
      let(:text) { 'http://www.mcmansionhell.com/post/156408871451/50-states-of-mcmansion-hell-scottsdale-arizona. ' }

      it 'matches the full URL but not the period' do
        expect(subject).to include 'href="http://www.mcmansionhell.com/post/156408871451/50-states-of-mcmansion-hell-scottsdale-arizona"'
      end
    end

    context 'when given a URL enclosed with parentheses' do
      let(:text) { '(http://google.com/)' }

      it 'matches the full URL but not the parentheses' do
        expect(subject).to include 'href="http://google.com/"'
      end
    end

    context 'when given a URL with a trailing exclamation point' do
      let(:text) { 'http://www.google.com!' }

      it 'matches the full URL but not the exclamation point' do
        expect(subject).to include 'href="http://www.google.com"'
      end
    end

    context 'when given a URL with a trailing single quote' do
      let(:text) { "http://www.google.com'" }

      it 'matches the full URL but not the single quote' do
        expect(subject).to include 'href="http://www.google.com"'
      end
    end

    context 'when given a URL with a trailing angle bracket' do
      let(:text) { 'http://www.google.com>' }

      it 'matches the full URL but not the angle bracket' do
        expect(subject).to include 'href="http://www.google.com"'
      end
    end

    context 'when given a URL with a query string' do
      context 'with escaped unicode character' do
        let(:text) { 'https://www.ruby-toolbox.com/search?utf8=%E2%9C%93&q=autolink' }

        it 'matches the full URL' do
          expect(subject).to include 'href="https://www.ruby-toolbox.com/search?utf8=%E2%9C%93&amp;q=autolink"'
        end
      end

      context 'with unicode character' do
        let(:text) { 'https://www.ruby-toolbox.com/search?utf8=✓&q=autolink' }

        it 'matches the full URL' do
          expect(subject).to include 'href="https://www.ruby-toolbox.com/search?utf8=✓&amp;q=autolink"'
        end
      end

      context 'with unicode character at the end' do
        let(:text) { 'https://www.ruby-toolbox.com/search?utf8=✓' }

        it 'matches the full URL' do
          expect(subject).to include 'href="https://www.ruby-toolbox.com/search?utf8=✓"'
        end
      end

      context 'with escaped and not escaped unicode characters' do
        let(:text) { 'https://www.ruby-toolbox.com/search?utf8=%E2%9C%93&utf81=✓&q=autolink' }

        it 'preserves escaped unicode characters' do
          expect(subject).to include 'href="https://www.ruby-toolbox.com/search?utf8=%E2%9C%93&amp;utf81=✓&amp;q=autolink"'
        end
      end
    end

    context 'when given a URL with parentheses in it' do
      let(:text) { 'https://en.wikipedia.org/wiki/Diaspora_(software)' }

      it 'matches the full URL' do
        expect(subject).to include 'href="https://en.wikipedia.org/wiki/Diaspora_(software)"'
      end
    end

    context 'when given a URL in quotation marks' do
      let(:text) { '"https://example.com/"' }

      it 'does not match the quotation marks' do
        expect(subject).to include 'href="https://example.com/"'
      end
    end

    context 'when given a URL in angle brackets' do
      let(:text) { '<https://example.com/>' }

      it 'does not match the angle brackets' do
        expect(subject).to include 'href="https://example.com/"'
      end
    end

    context 'when given a URL with Japanese path string' do
      let(:text) { 'https://ja.wikipedia.org/wiki/日本' }

      it 'matches the full URL' do
        expect(subject).to include 'href="https://ja.wikipedia.org/wiki/日本"'
      end
    end

    context 'when given a URL with Korean path string' do
      let(:text) { 'https://ko.wikipedia.org/wiki/대한민국' }

      it 'matches the full URL' do
        expect(subject).to include 'href="https://ko.wikipedia.org/wiki/대한민국"'
      end
    end

    context 'when given a URL with a full-width space' do
      let(:text) { 'https://example.com/　abc123' }

      it 'does not match the full-width space' do
        expect(subject).to include 'href="https://example.com/"'
      end
    end

    context 'when given a URL in Japanese quotation marks' do
      let(:text) { '「[https://example.org/」' }

      it 'does not match the quotation marks' do
        expect(subject).to include 'href="https://example.org/"'
      end
    end

    context 'when given a URL with Simplified Chinese path string' do
      let(:text) { 'https://baike.baidu.com/item/中华人民共和国' }

      it 'matches the full URL' do
        expect(subject).to include 'href="https://baike.baidu.com/item/中华人民共和国"'
      end
    end

    context 'when given a URL with Traditional Chinese path string' do
      let(:text) { 'https://zh.wikipedia.org/wiki/臺灣' }

      it 'matches the full URL' do
        expect(subject).to include 'href="https://zh.wikipedia.org/wiki/臺灣"'
      end
    end

    context 'when given a URL with trailing @ symbol' do
      let(:text) { 'https://gta.fandom.com/wiki/TW@ Content' }

      it 'matches the full URL' do
        expect(subject).to include 'href="https://gta.fandom.com/wiki/TW@"'
      end
    end

    context 'when given a URL containing unsafe code (XSS attack, visible part)' do
      let(:text) { 'http://example.com/b<del>b</del>' }

      it 'does not include the HTML in the URL' do
        expect(subject).to include '"http://example.com/b"'
      end

      it 'escapes the HTML' do
        expect(subject).to include '&lt;del&gt;b&lt;/del&gt;'
      end
    end

    context 'when given a URL containing unsafe code (XSS attack, invisible part)' do
      let(:text) { 'http://example.com/blahblahblahblah/a<script>alert("Hello")</script>' }

      it 'does not include the HTML in the URL' do
        expect(subject).to include '"http://example.com/blahblahblahblah/a"'
      end

      it 'escapes the HTML' do
        expect(subject).to include '&lt;script&gt;alert(&quot;Hello&quot;)&lt;/script&gt;'
      end
    end

    context 'when given text containing HTML code (script tag)' do
      let(:text) { '<script>alert("Hello")</script>' }

      it 'escapes the HTML' do
        expect(subject).to include '<p>&lt;script&gt;alert(&quot;Hello&quot;)&lt;/script&gt;</p>'
      end
    end

    context 'when given text containing HTML (XSS attack)' do
      let(:text) { %q{<img src="javascript:alert('XSS');">} }

      it 'escapes the HTML' do
        expect(subject).to include '<p>&lt;img src=&quot;javascript:alert(&#39;XSS&#39;);&quot;&gt;</p>'
      end
    end

    context 'when given an invalid URL' do
      let(:text) { 'http://www\.google\.com' }

      it 'outputs the raw URL' do
        expect(subject).to eq '<p>http://www\.google\.com</p>'
      end
    end

    context 'when given a lengthy URL' do
      let(:text) { 'lorem https://prepitaph.org/wip/web-dovespair/ ipsum' }

      it 'truncates the URL' do
        expect(subject).to include '<span class="invisible">https://</span>'
        expect(subject).to include '<span class="ellipsis">prepitaph.org/wip/web-dovespai</span>'
        expect(subject).to include '<span class="invisible">r/</span>'
      end
    end

    context 'when given a sufficiently short URL' do
      let(:text) { 'lorem https://prepitaph.org/wip/web-devspair/ ipsum' }

      it 'does not truncate the URL' do
        expect(subject).to include '<span class="invisible">https://</span>'
        expect(subject).to include '<span class="">prepitaph.org/wip/web-devspair/</span>'
        expect(subject).to include '<span class="invisible"></span>'
      end
    end

    context 'when given text containing a hashtag' do
      let(:text)  { '#hashtag' }

      it 'creates a hashtag link' do
        expect(subject).to include '/tags/hashtag" class="mention hashtag" rel="tag">#<span>hashtag</span></a>'
      end
    end

    context 'when given text containing a hashtag with Unicode chars' do
      let(:text)  { '#hashtagタグ' }

      it 'creates a hashtag link' do
        expect(subject).to include '/tags/hashtag%E3%82%BF%E3%82%B0" class="mention hashtag" rel="tag">#<span>hashtagタグ</span></a>'
      end
    end

    context 'when given text with a stand-alone xmpp: URI' do
      let(:text) { 'xmpp:user@instance.com' }

      it 'matches the full URI' do
        expect(subject).to include 'href="xmpp:user@instance.com"'
      end
    end

    context 'when given text with an xmpp: URI with a query-string' do
      let(:text) { 'please join xmpp:muc@instance.com?join right now' }

      it 'matches the full URI' do
        expect(subject).to include 'href="xmpp:muc@instance.com?join"'
      end
    end

    context 'when given text containing a magnet: URI' do
      let(:text) { 'wikipedia gives this example of a magnet uri: magnet:?xt=urn:btih:c12fe1c06bba254a9dc9f519b335aa7c1367a88a' }

      it 'matches the full URI' do
        expect(subject).to include 'href="magnet:?xt=urn:btih:c12fe1c06bba254a9dc9f519b335aa7c1367a88a"'
      end
    end
  end
end
