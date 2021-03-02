require 'rails_helper'

RSpec.describe Formatter do
  let(:local_account)  { Fabricate(:account, domain: nil, username: 'alice') }
  let(:remote_account) { Fabricate(:account, domain: 'remote.test', username: 'bob', url: 'https://remote.test/') }

  shared_examples 'encode and link URLs' do
    context 'given a stand-alone medium URL' do
      let(:text) { 'https://hackernoon.com/the-power-to-build-communities-a-response-to-mark-zuckerberg-3f2cac9148a4' }

      it 'matches the full URL' do
        is_expected.to include 'href="https://hackernoon.com/the-power-to-build-communities-a-response-to-mark-zuckerberg-3f2cac9148a4"'
      end
    end

    context 'given a stand-alone google URL' do
      let(:text) { 'http://google.com' }

      it 'matches the full URL' do
        is_expected.to include 'href="http://google.com"'
      end
    end

    context 'given a stand-alone URL with a newer TLD' do
      let(:text) { 'http://example.gay' }

      it 'matches the full URL' do
        is_expected.to include 'href="http://example.gay"'
      end
    end

    context 'given a stand-alone IDN URL' do
      let(:text) { 'https://nic.みんな/' }

      it 'matches the full URL' do
        is_expected.to include 'href="https://nic.みんな/"'
      end

      it 'has display URL' do
        is_expected.to include '<span class="">nic.みんな/</span>'
      end
    end

    context 'given a URL with a trailing period' do
      let(:text) { 'http://www.mcmansionhell.com/post/156408871451/50-states-of-mcmansion-hell-scottsdale-arizona. ' }

      it 'matches the full URL but not the period' do
        is_expected.to include 'href="http://www.mcmansionhell.com/post/156408871451/50-states-of-mcmansion-hell-scottsdale-arizona"'
      end
    end

    context 'given a URL enclosed with parentheses' do
      let(:text) { '(http://google.com/)' }

      it 'matches the full URL but not the parentheses' do
        is_expected.to include 'href="http://google.com/"'
      end
    end

    context 'given a URL with a trailing exclamation point' do
      let(:text) { 'http://www.google.com!' }

      it 'matches the full URL but not the exclamation point' do
        is_expected.to include 'href="http://www.google.com"'
      end
    end

    context 'given a URL with a trailing single quote' do
      let(:text) { "http://www.google.com'" }

      it 'matches the full URL but not the single quote' do
        is_expected.to include 'href="http://www.google.com"'
      end
    end

    context 'given a URL with a trailing angle bracket' do
      let(:text) { 'http://www.google.com>' }

      it 'matches the full URL but not the angle bracket' do
        is_expected.to include 'href="http://www.google.com"'
      end
    end

    context 'given a URL with a query string' do
      context 'with escaped unicode character' do
        let(:text) { 'https://www.ruby-toolbox.com/search?utf8=%E2%9C%93&q=autolink' }

        it 'matches the full URL' do
          is_expected.to include 'href="https://www.ruby-toolbox.com/search?utf8=%E2%9C%93&amp;q=autolink"'
        end
      end

      context 'with unicode character' do
        let(:text) { 'https://www.ruby-toolbox.com/search?utf8=✓&q=autolink' }

        it 'matches the full URL' do
          is_expected.to include 'href="https://www.ruby-toolbox.com/search?utf8=✓&amp;q=autolink"'
        end
      end

      context 'with unicode character at the end' do
        let(:text) { 'https://www.ruby-toolbox.com/search?utf8=✓' }

        it 'matches the full URL' do
          is_expected.to include 'href="https://www.ruby-toolbox.com/search?utf8=✓"'
        end
      end

      context 'with escaped and not escaped unicode characters' do
        let(:text) { 'https://www.ruby-toolbox.com/search?utf8=%E2%9C%93&utf81=✓&q=autolink' }

        it 'preserves escaped unicode characters' do
          is_expected.to include 'href="https://www.ruby-toolbox.com/search?utf8=%E2%9C%93&amp;utf81=✓&amp;q=autolink"'
        end
      end
    end

    context 'given a URL with parentheses in it' do
      let(:text) { 'https://en.wikipedia.org/wiki/Diaspora_(software)' }

      it 'matches the full URL' do
        is_expected.to include 'href="https://en.wikipedia.org/wiki/Diaspora_(software)"'
      end
    end

    context 'given a URL in quotation marks' do
      let(:text) { '"https://example.com/"' }

      it 'does not match the quotation marks' do
        is_expected.to include 'href="https://example.com/"'
      end
    end

    context 'given a URL in angle brackets' do
      let(:text) { '<https://example.com/>' }

      it 'does not match the angle brackets' do
        is_expected.to include 'href="https://example.com/"'
      end
    end

    context 'given a URL with Japanese path string' do
      let(:text) { 'https://ja.wikipedia.org/wiki/日本' }

      it 'matches the full URL' do
        is_expected.to include 'href="https://ja.wikipedia.org/wiki/日本"'
      end
    end

    context 'given a URL with Korean path string' do
      let(:text) { 'https://ko.wikipedia.org/wiki/대한민국' }

      it 'matches the full URL' do
        is_expected.to include 'href="https://ko.wikipedia.org/wiki/대한민국"'
      end
    end

    context 'given a URL with a full-width space' do
      let(:text) { 'https://example.com/　abc123' }

      it 'does not match the full-width space' do
        is_expected.to include 'href="https://example.com/"'
      end
    end

    context 'given a URL in Japanese quotation marks' do
      let(:text) { '「[https://example.org/」' }

      it 'does not match the quotation marks' do
        is_expected.to include 'href="https://example.org/"'
      end
    end

    context 'given a URL with Simplified Chinese path string' do
      let(:text) { 'https://baike.baidu.com/item/中华人民共和国' }

      it 'matches the full URL' do
        is_expected.to include 'href="https://baike.baidu.com/item/中华人民共和国"'
      end
    end

    context 'given a URL with Traditional Chinese path string' do
      let(:text) { 'https://zh.wikipedia.org/wiki/臺灣' }

      it 'matches the full URL' do
        is_expected.to include 'href="https://zh.wikipedia.org/wiki/臺灣"'
      end
    end

    context 'given a URL containing unsafe code (XSS attack, visible part)' do
      let(:text) { %q{http://example.com/b<del>b</del>} }

      it 'does not include the HTML in the URL' do
        is_expected.to include '"http://example.com/b"'
      end

      it 'escapes the HTML' do
        is_expected.to include '&lt;del&gt;b&lt;/del&gt;'
      end
    end

    context 'given a URL containing unsafe code (XSS attack, invisible part)' do
      let(:text) { %q{http://example.com/blahblahblahblah/a<script>alert("Hello")</script>} }

      it 'does not include the HTML in the URL' do
        is_expected.to include '"http://example.com/blahblahblahblah/a"'
      end

      it 'escapes the HTML' do
        is_expected.to include '&lt;script&gt;alert(&quot;Hello&quot;)&lt;/script&gt;'
      end
    end

    context 'given text containing HTML code (script tag)' do
      let(:text) { '<script>alert("Hello")</script>' }

      it 'escapes the HTML' do
        is_expected.to include '<p>&lt;script&gt;alert(&quot;Hello&quot;)&lt;/script&gt;</p>'
      end
    end

    context 'given text containing HTML (XSS attack)' do
      let(:text) { %q{<img src="javascript:alert('XSS');">} }

      it 'escapes the HTML' do
        is_expected.to include '<p>&lt;img src=&quot;javascript:alert(&apos;XSS&apos;);&quot;&gt;</p>'
      end
    end

    context 'given an invalid URL' do
      let(:text) { 'http://www\.google\.com' }

      it 'outputs the raw URL' do
        is_expected.to eq '<p>http://www\.google\.com</p>'
      end
    end

    context 'given text containing a hashtag' do
      let(:text)  { '#hashtag' }

      it 'creates a hashtag link' do
        is_expected.to include '/tags/hashtag" class="mention hashtag" rel="tag">#<span>hashtag</span></a>'
      end
    end

    context 'given text containing a hashtag with Unicode chars' do
      let(:text)  { '#hashtagタグ' }

      it 'creates a hashtag link' do
        is_expected.to include '/tags/hashtag%E3%82%BF%E3%82%B0" class="mention hashtag" rel="tag">#<span>hashtagタグ</span></a>'
      end
    end

    context 'given a stand-alone xmpp: URI' do
      let(:text) { 'xmpp:user@instance.com' }

      it 'matches the full URI' do
        is_expected.to include 'href="xmpp:user@instance.com"'
      end
    end

    context 'given a an xmpp: URI with a query-string' do
      let(:text) { 'please join xmpp:muc@instance.com?join right now' }

      it 'matches the full URI' do
        is_expected.to include 'href="xmpp:muc@instance.com?join"'
      end
    end

    context 'given text containing a magnet: URI' do
      let(:text) { 'wikipedia gives this example of a magnet uri: magnet:?xt=urn:btih:c12fe1c06bba254a9dc9f519b335aa7c1367a88a' }

      it 'matches the full URI' do
        is_expected.to include 'href="magnet:?xt=urn:btih:c12fe1c06bba254a9dc9f519b335aa7c1367a88a"'
      end
    end
  end

  describe '#format_spoiler' do
    subject { Formatter.instance.format_spoiler(status) }

    context 'given a post containing plain text' do
      let(:status) { Fabricate(:status, text: 'text', spoiler_text: 'Secret!', uri: nil) }

      it 'Returns the spoiler text' do
        is_expected.to eq 'Secret!'
      end
    end

    context 'given a post with an emoji shortcode at the start' do
      let!(:emoji) { Fabricate(:custom_emoji) }
      let(:status) { Fabricate(:status, text: 'text', spoiler_text: ':coolcat: Secret!', uri: nil) }
      let(:text) { ':coolcat: Beep boop' }

      it 'converts the shortcode to an image tag' do
        is_expected.to match(/<img draggable="false" class="emojione custom-emoji" alt=":coolcat:"/)
      end
    end
  end

  describe '#format' do
    subject { Formatter.instance.format(status) }

    context 'given a post with local status' do
      context 'given a reblogged post' do
        let(:reblog) { Fabricate(:status, account: local_account, text: 'Hello world', uri: nil) }
        let(:status) { Fabricate(:status, reblog: reblog) }

        it 'returns original status with credit to its author' do
          is_expected.to include 'RT <span class="h-card"><a href="https://cb6e6126.ngrok.io/@alice" class="u-url mention">@<span>alice</span></a></span> Hello world'
        end
      end

      context 'given a post containing plain text' do
        let(:status) { Fabricate(:status, text: 'text', uri: nil) }

        it 'paragraphizes the text' do
          is_expected.to eq '<p>text</p>'
        end
      end

      context 'given a post containing line feeds' do
        let(:status) { Fabricate(:status, text: "line\nfeed", uri: nil) }

        it 'removes line feeds' do
          is_expected.not_to include "\n"
        end
      end

      context 'given a post containing linkable mentions' do
        let(:status) { Fabricate(:status, mentions: [ Fabricate(:mention, account: local_account) ], text: '@alice') }

        it 'creates a mention link' do
          is_expected.to include '<a href="https://cb6e6126.ngrok.io/@alice" class="u-url mention">@<span>alice</span></a></span>'
        end
      end

      context 'given a post containing unlinkable mentions' do
        let(:status) { Fabricate(:status, text: '@alice', uri: nil) }

        it 'does not create a mention link' do
          is_expected.to include '@alice'
        end
      end

      context do
        let(:content_type) { 'text/plain' }

        subject do
          status = Fabricate(:status, text: text, content_type: content_type, uri: nil)
          Formatter.instance.format(status)
        end

        context 'given an invalid URL (invalid port)' do
          let(:text) { 'https://foo.bar:X/' }
          let(:content_type) { 'text/markdown' }

          it 'outputs the raw URL' do
            is_expected.to eq '<p>https://foo.bar:X/</p>'
          end
        end

        include_examples 'encode and link URLs'
      end

      context 'given a post with custom_emojify option' do
        let!(:emoji) { Fabricate(:custom_emoji) }
        let(:status) { Fabricate(:status, account: local_account, text: text) }

        subject { Formatter.instance.format(status, custom_emojify: true) }

        context 'given a post with an emoji shortcode at the start' do
          let(:text) { ':coolcat: Beep boop' }

          it 'converts the shortcode to an image tag' do
            is_expected.to match(/<p><img draggable="false" class="emojione custom-emoji" alt=":coolcat:"/)
          end
        end

        context 'given a post with an emoji shortcode in the middle' do
          let(:text) { 'Beep :coolcat: boop' }

          it 'converts the shortcode to an image tag' do
            is_expected.to match(/Beep <img draggable="false" class="emojione custom-emoji" alt=":coolcat:"/)
          end
        end

        context 'given a post with concatenated emoji shortcodes' do
          let(:text) { ':coolcat::coolcat:' }

          it 'does not touch the shortcodes' do
            is_expected.to match(/:coolcat::coolcat:/)
          end
        end

        context 'given a post with an emoji shortcode at the end' do
          let(:text) { 'Beep boop :coolcat:' }

          it 'converts the shortcode to an image tag' do
            is_expected.to match(/boop <img draggable="false" class="emojione custom-emoji" alt=":coolcat:"/)
          end
        end
      end
    end

    context 'given a post with remote status' do
      let(:status) { Fabricate(:status, account: remote_account, text: 'Beep boop') }

      it 'reformats the post' do
        is_expected.to eq 'Beep boop'
      end

      context 'given a post with custom_emojify option' do
        let!(:emoji) { Fabricate(:custom_emoji, domain: remote_account.domain) }
        let(:status) { Fabricate(:status, account: remote_account, text: text) }

        subject { Formatter.instance.format(status, custom_emojify: true) }

        context 'given a post with an emoji shortcode at the start' do
          let(:text) { '<p>:coolcat: Beep boop<br />' }

          it 'converts the shortcode to an image tag' do
            is_expected.to match(/<p><img draggable="false" class="emojione custom-emoji" alt=":coolcat:"/)
          end
        end

        context 'given a post with an emoji shortcode in the middle' do
          let(:text) { '<p>Beep :coolcat: boop</p>' }

          it 'converts the shortcode to an image tag' do
            is_expected.to match(/Beep <img draggable="false" class="emojione custom-emoji" alt=":coolcat:"/)
          end
        end

        context 'given a post with concatenated emoji' do
          let(:text) { '<p>:coolcat::coolcat:</p>' }

          it 'does not touch the shortcodes' do
            is_expected.to match(/<p>:coolcat::coolcat:<\/p>/)
          end
        end

        context 'given a post with an emoji shortcode at the end' do
          let(:text) { '<p>Beep boop<br />:coolcat:</p>' }

          it 'converts the shortcode to an image tag' do
            is_expected.to match(/<br><img draggable="false" class="emojione custom-emoji" alt=":coolcat:"/)
          end
        end
      end
    end
  end

  describe '#reformat' do
    subject { Formatter.instance.reformat(text) }

    context 'given a post containing plain text' do
      let(:text) { 'Beep boop' }

      it 'keeps the plain text' do
        is_expected.to include 'Beep boop'
      end
    end

    context 'given a post containing script tags' do
      let(:text) { '<script>alert("Hello")</script>' }

      it 'strips the scripts' do
        is_expected.to_not include '<script>alert("Hello")</script>'
      end
    end

    context 'given a post containing malicious classes' do
      let(:text) { '<span class="mention	status__content__spoiler-link">Show more</span>' }

      it 'strips the malicious classes' do
        is_expected.to_not include 'status__content__spoiler-link'
      end
    end
  end

  describe '#plaintext' do
    subject { Formatter.instance.plaintext(status) }

    context 'given a post with local status' do
      let(:status) { Fabricate(:status, text: '<p>a text by a nerd who uses an HTML tag in text</p>', content_type: content_type, uri: nil) }
      let(:content_type) { 'text/plain' }

      it 'returns the raw text' do
        is_expected.to eq '<p>a text by a nerd who uses an HTML tag in text</p>'
      end
    end

    context 'given a post with remote status' do
      let(:status) { Fabricate(:status, account: remote_account, text: '<script>alert("Hello")</script>') }

      it 'returns tag-stripped text' do
        is_expected.to eq ''
      end
    end
  end

  describe '#simplified_format' do
    subject { Formatter.instance.simplified_format(account) }

    context 'given a post with local status' do
      let(:account) { Fabricate(:account, domain: nil, note: text) }

      context 'given a post containing linkable mentions for local accounts' do
        let(:text) { '@alice' }

        before { local_account }

        it 'creates a mention link' do
          is_expected.to eq '<p><span class="h-card"><a href="https://cb6e6126.ngrok.io/@alice" class="u-url mention">@<span>alice</span></a></span></p>'
        end
      end

      context 'given a post containing linkable mentions for remote accounts' do
        let(:text) { '@bob@remote.test' }

        before { remote_account }

        it 'creates a mention link' do
          is_expected.to eq '<p><span class="h-card"><a href="https://remote.test/" class="u-url mention">@<span>bob</span></a></span></p>'
        end
      end

      context 'given a post containing unlinkable mentions' do
        let(:text) { '@alice' }

        it 'does not create a mention link' do
          is_expected.to eq '<p>@alice</p>'
        end
      end

      context 'given a post with custom_emojify option' do
        let!(:emoji) { Fabricate(:custom_emoji) }

        before { account.note = text }
        subject { Formatter.instance.simplified_format(account, custom_emojify: true) }

        context 'given a post with an emoji shortcode at the start' do
          let(:text) { ':coolcat: Beep boop' }

          it 'converts the shortcode to an image tag' do
            is_expected.to match(/<p><img draggable="false" class="emojione custom-emoji" alt=":coolcat:"/)
          end
        end

        context 'given a post with an emoji shortcode in the middle' do
          let(:text) { 'Beep :coolcat: boop' }

          it 'converts the shortcode to an image tag' do
            is_expected.to match(/Beep <img draggable="false" class="emojione custom-emoji" alt=":coolcat:"/)
          end
        end

        context 'given a post with concatenated emoji shortcodes' do
          let(:text) { ':coolcat::coolcat:' }

          it 'does not touch the shortcodes' do
            is_expected.to match(/:coolcat::coolcat:/)
          end
        end

        context 'given a post with an emoji shortcode at the end' do
          let(:text) { 'Beep boop :coolcat:' }

          it 'converts the shortcode to an image tag' do
            is_expected.to match(/boop <img draggable="false" class="emojione custom-emoji" alt=":coolcat:"/)
          end
        end
      end

      include_examples 'encode and link URLs'
    end

    context 'given a post with remote status' do
      let(:text) { '<script>alert("Hello")</script>' }
      let(:account) { Fabricate(:account, domain: 'remote', note: text) }

      it 'reformats' do
        is_expected.to_not include '<script>alert("Hello")</script>'
      end

      context 'with custom_emojify option' do
        let!(:emoji) { Fabricate(:custom_emoji, domain: remote_account.domain) }

        before { remote_account.note = text }

        subject { Formatter.instance.simplified_format(remote_account, custom_emojify: true) }

        context 'given a post with an emoji shortcode at the start' do
          let(:text) { '<p>:coolcat: Beep boop<br />' }

          it 'converts shortcode to image tag' do
            is_expected.to match(/<p><img draggable="false" class="emojione custom-emoji" alt=":coolcat:"/)
          end
        end

        context 'given a post with an emoji shortcode in the middle' do
          let(:text) { '<p>Beep :coolcat: boop</p>' }

          it 'converts shortcode to image tag' do
            is_expected.to match(/Beep <img draggable="false" class="emojione custom-emoji" alt=":coolcat:"/)
          end
        end

        context 'given a post with concatenated emoji shortcodes' do
          let(:text) { '<p>:coolcat::coolcat:</p>' }

          it 'does not touch the shortcodes' do
            is_expected.to match(/<p>:coolcat::coolcat:<\/p>/)
          end
        end

        context 'given a post with an emoji shortcode at the end' do
          let(:text) { '<p>Beep boop<br />:coolcat:</p>' }

          it 'converts shortcode to image tag' do
            is_expected.to match(/<br><img draggable="false" class="emojione custom-emoji" alt=":coolcat:"/)
          end
        end
      end
    end
  end

  describe '#sanitize' do
    let(:html) { '<script>alert("Hello")</script>' }

    subject { Formatter.instance.sanitize(html, Sanitize::Config::MASTODON_STRICT) }

    it 'sanitizes' do
      is_expected.to eq ''
    end
  end
end
