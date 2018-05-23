# encoding: utf-8
require File.dirname(__FILE__) + '/spec_helper'

class TestAutolink
  include Twitter::Autolink
end

describe Twitter::Autolink do
  def original_text; end
  def url; end

  describe "auto_link_custom" do
    before do
      @autolinked_text = TestAutolink.new.auto_link(original_text) if original_text
    end

    describe "username autolinking" do
      context "username preceded by a space" do
        def original_text; "hello @jacob"; end

        it "should be linked" do
          @autolinked_text.should link_to_screen_name('jacob')
        end
      end

      context "username in camelCase" do
        def original_text() "@jaCob iS cOoL" end

        it "should be linked" do
          @autolinked_text.should link_to_screen_name('jaCob')
        end
      end

      context "username at beginning of line" do
        def original_text; "@jacob you're cool"; end

        it "should be linked" do
          @autolinked_text.should link_to_screen_name('jacob')
        end
      end

      context "username preceded by word character" do
        def original_text; "meet@the beach"; end

        it "should not be linked" do
          Nokogiri::HTML(@autolinked_text).search('a').should be_empty
        end
      end

      context "username preceded by non-word character" do
        def original_text; "great.@jacob"; end

        it "should be linked" do
          @autolinked_text.should link_to_screen_name('jacob')
        end
      end

      context "username containing non-word characters" do
        def original_text; "@zach&^$%^"; end

        it "should not be linked" do
          @autolinked_text.should link_to_screen_name('zach')
        end
      end

      context "username over twenty characters" do
        def original_text
          @twenty_character_username = "zach" * 5
          "@" + @twenty_character_username + "1"
        end

        it "should not be linked" do
          @autolinked_text.should link_to_screen_name(@twenty_character_username)
        end
      end

      context "username followed by japanese" do
        def original_text; "@jacobの"; end

        it "should be linked" do
          @autolinked_text.should link_to_screen_name('jacob')
        end
      end

      context "username preceded by japanese" do
        def original_text; "あ@matz"; end

        it "should be linked" do
          @autolinked_text.should link_to_screen_name('matz')
        end
      end

      context "username surrounded by japanese" do
        def original_text; "あ@yoshimiの"; end

        it "should be linked" do
          @autolinked_text.should link_to_screen_name('yoshimi')
        end
      end

      context "username using full-width at-sign" do
        def original_text
          "#{[0xFF20].pack('U')}jacob"
        end

        it "should be linked" do
          @autolinked_text.should link_to_screen_name('jacob')
        end
      end
    end

    describe "list path autolinking" do

      context "when List is not available" do
        it "should not be linked" do
          @autolinked_text = TestAutolink.new.auto_link_usernames_or_lists("hello @jacob/my-list", :suppress_lists => true)
          @autolinked_text.should_not link_to_list_path('jacob/my-list')
          @autolinked_text.should include('my-list')
        end
      end

      context "slug preceded by a space" do
        def original_text; "hello @jacob/my-list"; end

        it "should be linked" do
          @autolinked_text.should link_to_list_path('jacob/my-list')
        end
      end

      context "username followed by a slash but no list" do
        def original_text; "hello @jacob/ my-list"; end

        it "should NOT be linked" do
          @autolinked_text.should_not link_to_list_path('jacob/my-list')
          @autolinked_text.should link_to_screen_name('jacob')
        end
      end

      context "empty username followed by a list" do
        def original_text; "hello @/my-list"; end

        it "should NOT be linked" do
          Nokogiri::HTML(@autolinked_text).search('a').should be_empty
        end
      end

      context "list slug at beginning of line" do
        def original_text; "@jacob/my-list"; end

        it "should be linked" do
          @autolinked_text.should link_to_list_path('jacob/my-list')
        end
      end

      context "username preceded by alpha-numeric character" do
        def original_text; "meet@the/beach"; end

        it "should not be linked" do
          Nokogiri::HTML(@autolinked_text).search('a').should be_empty
        end
      end

      context "username preceded by non-word character" do
        def original_text; "great.@jacob/my-list"; end

        it "should be linked" do
          @autolinked_text = TestAutolink.new.auto_link("great.@jacob/my-list")
          @autolinked_text.should link_to_list_path('jacob/my-list')
        end
      end

      context "username containing non-word characters" do
        def original_text; "@zach/test&^$%^"; end

        it "should be linked" do
          @autolinked_text.should link_to_list_path('zach/test')
        end
      end

      context "username over twenty characters" do
        def original_text
          @twentyfive_character_list = "jack/" + ("a" * 25)
          "@#{@twentyfive_character_list}12345"
        end

        it "should be linked" do
          @autolinked_text.should link_to_list_path(@twentyfive_character_list)
        end
      end
    end

    describe "hashtag autolinking" do
      context "with an all numeric hashtag" do
        def original_text; "#123"; end

        it "should not be linked" do
          @autolinked_text.should_not have_autolinked_hashtag('#123')
        end
      end

      context "with a hashtag with alphanumeric characters" do
        def original_text; "#ab1d"; end

        it "should be linked" do
          @autolinked_text.should have_autolinked_hashtag('#ab1d')
        end
      end

      context "with a hashtag with underscores" do
        def original_text; "#a_b_c_d"; end

        it "should be linked" do
          @autolinked_text.should have_autolinked_hashtag(original_text)
        end
      end

      context "with a hashtag that is preceded by a word character" do
        def original_text; "ab#cd"; end

        it "should not be linked" do
          @autolinked_text.should_not have_autolinked_hashtag(original_text)
        end
      end

      context "with a page anchor in a url" do
        def original_text; "Here's my url: http://foobar.com/#home"; end

        it "should not link the hashtag" do
          @autolinked_text.should_not have_autolinked_hashtag('#home')
        end

        it "should link the url" do
          @autolinked_text.should have_autolinked_url('http://foobar.com/#home')
        end
      end

      context "with a hashtag that starts with a number but has word characters" do
        def original_text; "#2ab"; end

        it "should be linked" do
          @autolinked_text.should have_autolinked_hashtag(original_text)
        end
      end

      context "with multiple valid hashtags" do
        def original_text; "I'm frickin' awesome #ab #cd #ef"; end

        it "links each hashtag" do
          @autolinked_text.should have_autolinked_hashtag('#ab')
          @autolinked_text.should have_autolinked_hashtag('#cd')
          @autolinked_text.should have_autolinked_hashtag('#ef')
        end
      end

      context "with a hashtag preceded by a ." do
        def original_text; "ok, great.#abc"; end

        it "should be linked" do
          @autolinked_text.should have_autolinked_hashtag('#abc')
        end
      end

      context "with a hashtag preceded by a &" do
        def original_text; "&#nbsp;"; end

        it "should not be linked" do
          @autolinked_text.should_not have_autolinked_hashtag('#nbsp;')
        end
      end

      context "with a hashtag that ends in an !" do
        def original_text; "#great!"; end

        it "should be linked, but should not include the !" do
          @autolinked_text.should have_autolinked_hashtag('#great')
        end
      end

      context "with a hashtag followed by Japanese" do
         def original_text; "#twj_devの"; end

        it "should be linked" do
          @autolinked_text.should have_autolinked_hashtag('#twj_devの')
        end
      end

      context "with a hashtag preceded by a full-width space" do
        def original_text; "#{[0x3000].pack('U')}#twj_dev"; end

        it "should be linked" do
          @autolinked_text.should have_autolinked_hashtag('#twj_dev')
        end
      end

      context "with a hashtag followed by a full-width space" do
        def original_text; "#twj_dev#{[0x3000].pack('U')}"; end

        it "should be linked" do
          @autolinked_text.should have_autolinked_hashtag('#twj_dev')
        end
      end

      context "with a hashtag using full-width hash" do
        def original_text; "#{[0xFF03].pack('U')}twj_dev"; end

        it "should be linked" do
          link = Nokogiri::HTML(@autolinked_text).search('a')
          (link.inner_text.respond_to?(:force_encoding) ? link.inner_text.force_encoding("utf-8") : link.inner_text).should == "#{[0xFF03].pack('U')}twj_dev"
          link.first['href'].should == 'https://twitter.com/#!/search?q=%23twj_dev'
        end
      end

      context "with a hashtag containing an accented latin character" do
        def original_text
          # the hashtag is #éhashtag
          "##{[0x00e9].pack('U')}hashtag"
        end

        it "should be linked" do
          @autolinked_text.should == "<a class=\"tweet-url hashtag\" href=\"https://twitter.com/#!/search?q=%23éhashtag\" rel=\"nofollow\" title=\"#éhashtag\">#éhashtag</a>"
        end
      end

    end

    describe "URL autolinking" do
      def url; "http://www.google.com"; end

      context "when embedded in plain text" do
        def original_text; "On my search engine #{url} I found good links."; end

        it "should be linked" do
          @autolinked_text.should have_autolinked_url(url)
        end
      end

      context "when surrounded by Japanese;" do
        def original_text; "いまなにしてる#{url}いまなにしてる"; end

        it "should be linked" do
          @autolinked_text.should have_autolinked_url(url)
        end
      end

      context "with a path surrounded by parentheses;" do
        def original_text; "I found a neatness (#{url})"; end

        it "should be linked" do
          @autolinked_text.should have_autolinked_url(url)
        end

        context "when the URL ends with a slash;" do
          def url; "http://www.google.com/"; end

          it "should be linked" do
            @autolinked_text.should have_autolinked_url(url)
          end
        end

        context "when the URL has a path;" do
          def url; "http://www.google.com/fsdfasdf"; end

          it "should be linked" do
            @autolinked_text.should have_autolinked_url(url)
          end
        end
      end

      context "when path contains parens" do
        def original_text; "I found a neatness (#{url})"; end

        it "should be linked" do
          @autolinked_text.should have_autolinked_url(url)
        end

        context "wikipedia" do
          def url; "http://en.wikipedia.org/wiki/Madonna_(artist)"; end

          it "should be linked" do
            @autolinked_text.should have_autolinked_url(url)
          end
        end

        context "IIS session" do
          def url; "http://msdn.com/S(deadbeef)/page.htm"; end

          it "should be linked" do
            @autolinked_text.should have_autolinked_url(url)
          end
        end

        context "unbalanced parens" do
          def url; "http://example.com/i_has_a_("; end

          it "should be linked" do
            @autolinked_text.should have_autolinked_url("http://example.com/i_has_a_")
          end
        end

        context "balanced parens with a double quote inside" do
          def url; "http://foo.com/foo_(\")_bar" end

          it "should be linked" do
            @autolinked_text.should have_autolinked_url("http://foo.com/foo_")
          end
        end

        context "balanced parens hiding XSS" do
          def url; 'http://x.xx.com/("style="color:red"onmouseover="alert(1)' end

          it "should be linked" do
            @autolinked_text.should have_autolinked_url("http://x.xx.com/")
          end
        end
      end

      context "when preceded by a :" do
        def original_text; "Check this out @hoverbird:#{url}"; end

        it "should be linked" do
          @autolinked_text.should have_autolinked_url(url)
        end
      end

      context "with a URL ending in allowed punctuation" do
        it "does not consume ending punctuation" do
          matcher = TestAutolink.new
          %w| ? ! , . : ; ] ) } = \ ' |.each do |char|
            matcher.auto_link("#{url}#{char}").should have_autolinked_url(url)
          end
        end
      end

      context "with a URL preceded in forbidden characters" do
        it "should be linked" do
          matcher = TestAutolink.new
          %w| \ ' / ! = |.each do |char|
            matcher.auto_link("#{char}#{url}").should have_autolinked_url(url)
          end
        end
      end

      context "when embedded in a link tag" do
        def original_text; "<link rel='true'>#{url}</link>"; end

        it "should be linked" do
          @autolinked_text.should have_autolinked_url(url)
        end
      end

      context "with multiple URLs" do
        def original_text; "http://www.links.org link at start of page, link at end http://www.foo.org"; end

        it "should autolink each one" do
          @autolinked_text.should have_autolinked_url('http://www.links.org')
          @autolinked_text.should have_autolinked_url('http://www.foo.org')
        end
      end

      context "with multiple URLs in different formats" do
        def original_text; "http://foo.com https://bar.com http://mail.foobar.org"; end

        it "should autolink each one, in the proper order" do
          @autolinked_text.should have_autolinked_url('http://foo.com')
          @autolinked_text.should have_autolinked_url('https://bar.com')
          @autolinked_text.should have_autolinked_url('http://mail.foobar.org')
        end
      end

      context "with a URL having a long TLD" do
        def original_text; "Yahoo integriert Facebook http://golem.mobi/0912/71607.html"; end

        it "should autolink it" do
          @autolinked_text.should have_autolinked_url('http://golem.mobi/0912/71607.html')
        end
      end

      context "with a url lacking the protocol" do
        def original_text; "I like www.foobar.com dudes"; end

        it "does not link at all" do
          link = Nokogiri::HTML(@autolinked_text).search('a')
          link.should be_empty
        end
      end

      context "with a @ in a URL" do
        context "with XSS attack" do
          def original_text; 'http://x.xx.com/@"style="color:pink"onmouseover=alert(1)//'; end

          it "should not allow XSS follwing @" do
            @autolinked_text.should have_autolinked_url('http://x.xx.com/')
          end
        end

        context "with a username not followed by a /" do
          def original_text; 'http://example.com/@foobar'; end

          it "should link url" do
            @autolinked_text.should have_autolinked_url('http://example.com/@foobar')
          end
        end

        context "with a username followed by a /" do
          def original_text; 'http://example.com/@foobar/'; end

          it "should not link the username but link full url" do
            @autolinked_text.should have_autolinked_url('http://example.com/@foobar/')
            @autolinked_text.should_not link_to_screen_name('foobar')
          end
        end
      end

      context "regex engine quirks" do
        context "does not spiral out of control on repeated periods" do
          def original_text; "Test a ton of periods http://example.com/path.........................................."; end

          it "should autolink" do
            @autolinked_text.should have_autolinked_url('http://example.com/path')
          end
        end

        context "does not spiral out of control on repeated dashes" do
          def original_text; "Single char file ext http://www.bestbuy.com/site/Currie+Technologies+-+Ezip+400+Scooter/9885188.p?id=1218189013070&skuId=9885188"; end

          it "should autolink" do
            @autolinked_text.should have_autolinked_url('http://www.bestbuy.com/site/Currie+Technologies+-+Ezip+400+Scooter/9885188.p?id=1218189013070&skuId=9885188')
          end
        end
      end

    end

    describe "Autolink all" do
      before do
        @linker = TestAutolink.new
      end

      it "should allow url/hashtag overlap" do
        auto_linked = @linker.auto_link("https://twitter.com/#search")
        auto_linked.should have_autolinked_url('https://twitter.com/#search')
      end

      it "should not add invalid option in HTML tags" do
        auto_linked = @linker.auto_link("https://twitter.com/ is a URL, not a hashtag", :hashtag_class => 'hashtag_classname')
        auto_linked.should have_autolinked_url('https://twitter.com/')
        auto_linked.should_not include('hashtag_class')
        auto_linked.should_not include('hashtag_classname')
      end

      it "should autolink url/hashtag/mention in text with Unicode supplementary characters" do
        auto_linked = @linker.auto_link("#{[0x10400].pack('U')} #hashtag #{[0x10400].pack('U')} @mention #{[0x10400].pack('U')} http://twitter.com/")
        auto_linked.should have_autolinked_hashtag('#hashtag')
        auto_linked.should link_to_screen_name('mention')
        auto_linked.should have_autolinked_url('http://twitter.com/')
      end
    end

  end

  describe "autolinking options" do
    before do
      @linker = TestAutolink.new
    end

    it "should show display_url when :url_entities provided" do
      linked = @linker.auto_link("http://t.co/0JG5Mcq", :url_entities => [{
        "url" => "http://t.co/0JG5Mcq",
        "display_url" => "blog.twitter.com/2011/05/twitte…",
        "expanded_url" => "http://blog.twitter.com/2011/05/twitter-for-mac-update.html",
        "indices" => [
          84,
          103
        ]
      }])
      html = Nokogiri::HTML(linked)
      html.search('a').should_not be_empty
      html.search('a[@href="http://t.co/0JG5Mcq"]').should_not be_empty
      html.search('span[@class=js-display-url]').inner_text.should == "blog.twitter.com/2011/05/twitte"
      html.inner_text.should == " http://blog.twitter.com/2011/05/twitter-for-mac-update.html …"
      html.search('span[@style="position:absolute;left:-9999px;"]').size.should == 4
    end

    it "should accept invisible_tag_attrs option" do
      linked = @linker.auto_link("http://t.co/0JG5Mcq",
        {
          :url_entities => [{
            "url" => "http://t.co/0JG5Mcq",
            "display_url" => "blog.twitter.com/2011/05/twitte…",
            "expanded_url" => "http://blog.twitter.com/2011/05/twitter-for-mac-update.html",
            "indices" => [
              0,
              19
            ]
          }],
          :invisible_tag_attrs => "style='dummy;'"
      })
      html = Nokogiri::HTML(linked)
      html.search('span[@style="dummy;"]').size.should == 4
    end

    it "should show display_url if available in entity" do
      linked = @linker.auto_link_entities("http://t.co/0JG5Mcq",
        [{
          :url => "http://t.co/0JG5Mcq",
          :display_url => "blog.twitter.com/2011/05/twitte…",
          :expanded_url => "http://blog.twitter.com/2011/05/twitter-for-mac-update.html",
          :indices => [0, 19]
        }]
      )
      html = Nokogiri::HTML(linked)
      html.search('a').should_not be_empty
      html.search('a[@href="http://t.co/0JG5Mcq"]').should_not be_empty
      html.search('span[@class=js-display-url]').inner_text.should == "blog.twitter.com/2011/05/twitte"
      html.inner_text.should == " http://blog.twitter.com/2011/05/twitter-for-mac-update.html …"
    end

    it "should apply :class as a CSS class" do
      linked = @linker.auto_link("http://example.com/", :class => 'myclass')
      linked.should have_autolinked_url('http://example.com/')
      linked.should match(/myclass/)
    end

    it "should apply :url_class only on URL" do
      linked = @linker.auto_link("http://twitter.com")
      linked.should have_autolinked_url('http://twitter.com')
      linked.should_not match(/class/)

      linked = @linker.auto_link("http://twitter.com", :url_class => 'testClass')
      linked.should have_autolinked_url('http://twitter.com')
      linked.should match(/class=\"testClass\"/)

      linked = @linker.auto_link("#hash @tw", :url_class => 'testClass')
      linked.should match(/class=\"tweet-url hashtag\"/)
      linked.should match(/class=\"tweet-url username\"/)
      linked.should_not match(/class=\"testClass\"/)
    end

    it "should add rel=nofollow by default" do
      linked = @linker.auto_link("http://example.com/")
      linked.should have_autolinked_url('http://example.com/')
      linked.should match(/nofollow/)
    end

    it "should include the '@' symbol in a username when passed :username_include_symbol" do
      linked = @linker.auto_link("@user", :username_include_symbol => true)
      linked.should link_to_screen_name('user', '@user')
    end

    it "should include the '@' symbol in a list when passed :username_include_symbol" do
      linked = @linker.auto_link("@user/list", :username_include_symbol => true)
      linked.should link_to_list_path('user/list', '@user/list')
    end

    it "should not add rel=nofollow when passed :suppress_no_follow" do
      linked = @linker.auto_link("http://example.com/", :suppress_no_follow => true)
      linked.should have_autolinked_url('http://example.com/')
      linked.should_not match(/nofollow/)
    end

    it "should not add a target attribute by default" do
      linked = @linker.auto_link("http://example.com/")
      linked.should have_autolinked_url('http://example.com/')
      linked.should_not match(/target=/)
    end

    it "should respect the :target option" do
      linked = @linker.auto_link("http://example.com/", :target => 'mywindow')
      linked.should have_autolinked_url('http://example.com/')
      linked.should match(/target="mywindow"/)
    end

    it "should customize href by username_url_block option" do
      linked = @linker.auto_link("@test", :username_url_block => lambda{|a| "dummy"})
      linked.should have_autolinked_url('dummy', 'test')
    end

    it "should customize href by list_url_block option" do
      linked = @linker.auto_link("@test/list", :list_url_block => lambda{|a| "dummy"})
      linked.should have_autolinked_url('dummy', 'test/list')
    end

    it "should customize href by hashtag_url_block option" do
      linked = @linker.auto_link("#hashtag", :hashtag_url_block => lambda{|a| "dummy"})
      linked.should have_autolinked_url('dummy', '#hashtag')
    end

    it "should customize href by cashtag_url_block option" do
      linked = @linker.auto_link("$CASH", :cashtag_url_block => lambda{|a| "dummy"})
      linked.should have_autolinked_url('dummy', '$CASH')
    end

    it "should customize href by link_url_block option" do
      linked = @linker.auto_link("http://example.com/", :link_url_block => lambda{|a| "dummy"})
      linked.should have_autolinked_url('dummy', 'http://example.com/')
    end

    it "should modify link attributes by link_attribute_block" do
      linked = @linker.auto_link("#hash @mention",
        :link_attribute_block => lambda{|entity, attributes|
          attributes[:"dummy-hash-attr"] = "test" if entity[:hashtag]
        }
      )
      linked.should match(/<a[^>]+hashtag[^>]+dummy-hash-attr=\"test\"[^>]+>/)
      linked.should_not match(/<a[^>]+username[^>]+dummy-hash-attr=\"test\"[^>]+>/)
      linked.should_not match(/link_attribute_block/i)

      linked = @linker.auto_link("@mention http://twitter.com/",
        :link_attribute_block => lambda{|entity, attributes|
          attributes["dummy-url-attr"] = entity[:url] if entity[:url]
        }
      )
      linked.should_not match(/<a[^>]+username[^>]+dummy-url-attr=\"http:\/\/twitter.com\/\"[^>]*>/)
      linked.should match(/<a[^>]+dummy-url-attr=\"http:\/\/twitter.com\/\"/)
    end

    it "should modify link text by link_text_block" do
      linked = @linker.auto_link("#hash @mention",
        :link_text_block => lambda{|entity, text|
          entity[:hashtag] ? "#replaced" : "pre_#{text}_post"
        }
      )
      linked.should match(/<a[^>]+>#replaced<\/a>/)
      linked.should match(/<a[^>]+>pre_mention_post<\/a>/)

      linked = @linker.auto_link("#hash @mention", {
        :link_text_block => lambda{|entity, text|
          "pre_#{text}_post"
        },
        :symbol_tag => "s", :text_with_symbol_tag => "b", :username_include_symbol => true
      })
      linked.should match(/<a[^>]+>pre_<s>#<\/s><b>hash<\/b>_post<\/a>/)
      linked.should match(/<a[^>]+>pre_<s>@<\/s><b>mention<\/b>_post<\/a>/)
    end

    it "should apply :url_target only to auto-linked URLs" do
      auto_linked = @linker.auto_link("#hashtag @mention http://test.com/", {:url_target => '_blank'})
      auto_linked.should have_autolinked_hashtag('#hashtag')
      auto_linked.should link_to_screen_name('mention')
      auto_linked.should have_autolinked_url('http://test.com/')
      auto_linked.should_not match(/<a[^>]+hashtag[^>]+target[^>]+>/)
      auto_linked.should_not match(/<a[^>]+username[^>]+target[^>]+>/)
      auto_linked.should match(/<a[^>]+test.com[^>]+target=\"_blank\"[^>]*>/)
    end

    it "should apply target='_blank' only to auto-linked URLs when :target_blank is set to true" do
      auto_linked = @linker.auto_link("#hashtag @mention http://test.com/", {:target_blank => true})
      auto_linked.should have_autolinked_hashtag('#hashtag')
      auto_linked.should link_to_screen_name('mention')
      auto_linked.should have_autolinked_url('http://test.com/')
      auto_linked.should match(/<a[^>]+hashtag[^>]+target=\"_blank\"[^>]*>/)
      auto_linked.should match(/<a[^>]+username[^>]+target=\"_blank\"[^>]*>/)
      auto_linked.should match(/<a[^>]+test.com[^>]+target=\"_blank\"[^>]*>/)
    end
  end

  describe "link_url_with_entity" do
    before do
      @linker = TestAutolink.new
    end

    it "should use display_url and expanded_url" do
      @linker.send(:link_url_with_entity,
        {
          :url => "http://t.co/abcde",
          :display_url => "twitter.com",
          :expanded_url => "http://twitter.com/"},
        {:invisible_tag_attrs => "class='invisible'"}).gsub('"', "'").should == "<span class='tco-ellipsis'><span class='invisible'>&nbsp;</span></span><span class='invisible'>http://</span><span class='js-display-url'>twitter.com</span><span class='invisible'>/</span><span class='tco-ellipsis'><span class='invisible'>&nbsp;</span></span>";
    end

    it "should correctly handle display_url ending with '…'" do
      @linker.send(:link_url_with_entity,
        {
          :url => "http://t.co/abcde",
          :display_url => "twitter.com…",
          :expanded_url => "http://twitter.com/abcdefg"},
        {:invisible_tag_attrs => "class='invisible'"}).gsub('"', "'").should == "<span class='tco-ellipsis'><span class='invisible'>&nbsp;</span></span><span class='invisible'>http://</span><span class='js-display-url'>twitter.com</span><span class='invisible'>/abcdefg</span><span class='tco-ellipsis'><span class='invisible'>&nbsp;</span>…</span>";
    end

    it "should correctly handle display_url starting with '…'" do
      @linker.send(:link_url_with_entity,
        {
          :url => "http://t.co/abcde",
          :display_url => "…tter.com/abcdefg",
          :expanded_url => "http://twitter.com/abcdefg"},
        {:invisible_tag_attrs => "class='invisible'"}).gsub('"', "'").should == "<span class='tco-ellipsis'>…<span class='invisible'>&nbsp;</span></span><span class='invisible'>http://twi</span><span class='js-display-url'>tter.com/abcdefg</span><span class='invisible'></span><span class='tco-ellipsis'><span class='invisible'>&nbsp;</span></span>";
    end

    it "should not create spans if display_url and expanded_url are on different domains" do
      @linker.send(:link_url_with_entity,
        {
          :url => "http://t.co/abcde",
          :display_url => "pic.twitter.com/xyz",
          :expanded_url => "http://twitter.com/foo/statuses/123/photo/1"},
        {:invisible_tag_attrs => "class='invisible'"}).gsub('"', "'").should == "pic.twitter.com/xyz"
    end
  end

  describe "symbol_tag" do
    before do
      @linker = TestAutolink.new
    end
    it "should put :symbol_tag around symbol" do
      @linker.auto_link("@mention", {:symbol_tag => 's', :username_include_symbol=>true}).should match(/<s>@<\/s>mention/)
      @linker.auto_link("#hash", {:symbol_tag => 's'}).should match(/<s>#<\/s>hash/)
      result = @linker.auto_link("@mention #hash $CASH", {:symbol_tag => 'b', :username_include_symbol=>true})
      result.should match(/<b>@<\/b>mention/)
      result.should match(/<b>#<\/b>hash/)
      result.should match(/<b>\$<\/b>CASH/)
    end
    it "should put :text_with_symbol_tag around text" do
      result = @linker.auto_link("@mention #hash $CASH", {:text_with_symbol_tag => 'b'})
      result.should match(/<b>mention<\/b>/)
      result.should match(/<b>hash<\/b>/)
      result.should match(/<b>CASH<\/b>/)
    end
    it "should put :symbol_tag around symbol and :text_with_symbol_tag around text" do
      result = @linker.auto_link("@mention #hash $CASH", {:symbol_tag => 's', :text_with_symbol_tag => 'b', :username_include_symbol=>true})
      result.should match(/<s>@<\/s><b>mention<\/b>/)
      result.should match(/<s>#<\/s><b>hash<\/b>/)
      result.should match(/<s>\$<\/s><b>CASH<\/b>/)
    end
  end

  describe "html_escape" do
    before do
      @linker = TestAutolink.new
    end
    it "should escape html entities properly" do
      @linker.html_escape("&").should == "&amp;"
      @linker.html_escape(">").should == "&gt;"
      @linker.html_escape("<").should == "&lt;"
      @linker.html_escape("\"").should == "&quot;"
      @linker.html_escape("'").should == "&#39;"
      @linker.html_escape("&<>\"").should == "&amp;&lt;&gt;&quot;"
      @linker.html_escape("<div>").should == "&lt;div&gt;"
      @linker.html_escape("a&b").should == "a&amp;b"
      @linker.html_escape("<a href=\"https://twitter.com\" target=\"_blank\">twitter & friends</a>").should == "&lt;a href=&quot;https://twitter.com&quot; target=&quot;_blank&quot;&gt;twitter &amp; friends&lt;/a&gt;"
      @linker.html_escape("&amp;").should == "&amp;amp;"
      @linker.html_escape(nil).should == nil
    end
  end

end
