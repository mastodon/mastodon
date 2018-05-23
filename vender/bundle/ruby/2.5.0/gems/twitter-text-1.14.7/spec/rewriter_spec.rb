# encoding: utf-8
require File.dirname(__FILE__) + '/spec_helper'

describe Twitter::Rewriter do
  def original_text; end
  def url; end

  def block(*args)
    if Array === @block_args
      unless Array === @block_args.first
        @block_args = [@block_args]
      end
      @block_args << args
    else
      @block_args = args
    end
    "[rewritten]"
  end

  describe "rewrite usernames" do #{{{
    before do
      @rewritten_text = Twitter::Rewriter.rewrite_usernames_or_lists(original_text, &method(:block))
    end

    context "username preceded by a space" do
      def original_text; "hello @jacob"; end

      it "should be rewritten" do
        @block_args.should == ["@", "jacob", nil]
        @rewritten_text.should == "hello [rewritten]"
      end
    end

    context "username at beginning of line" do
      def original_text; "@jacob you're cool"; end

      it "should be rewritten" do
        @block_args.should == ["@", "jacob", nil]
        @rewritten_text.should == "[rewritten] you're cool"
      end
    end

    context "username preceded by word character" do
      def original_text; "meet@the beach"; end

      it "should not be rewritten" do
        @block_args.should be_nil
        @rewritten_text.should == "meet@the beach"
      end
    end

    context "username preceded by non-word character" do
      def original_text; "great.@jacob"; end

      it "should be rewritten" do
        @block_args.should == ["@", "jacob", nil]
        @rewritten_text.should == "great.[rewritten]"
      end
    end

    context "username containing non-word characters" do
      def original_text; "@jacob&^$%^"; end

      it "should be rewritten" do
        @block_args.should == ["@", "jacob", nil]
        @rewritten_text.should == "[rewritten]&^$%^"
      end
    end

    context "username over twenty characters" do
      def original_text
        @twenty_character_username = "zach" * 5
        "@" + @twenty_character_username + "1"
      end

      it "should be rewritten" do
        @block_args.should == ["@", @twenty_character_username, nil]
        @rewritten_text.should == "[rewritten]1"
      end
    end

    context "username followed by japanese" do
      def original_text; "@jacobの"; end

      it "should be rewritten" do
        @block_args.should == ["@", "jacob", nil]
        @rewritten_text.should == "[rewritten]の"
      end
    end

    context "username preceded by japanese" do
      def original_text; "あ@jacob"; end

      it "should be rewritten" do
        @block_args.should == ["@", "jacob", nil]
        @rewritten_text.should == "あ[rewritten]"
      end
    end

    context "username surrounded by japanese" do
      def original_text; "あ@jacobの"; end

      it "should be rewritten" do
        @block_args.should == ["@", "jacob", nil]
        @rewritten_text.should == "あ[rewritten]の"
      end
    end

    context "username using full-width at-sign" do
      def original_text
        "#{[0xFF20].pack('U')}jacob"
      end

      it "should be rewritten" do
        @block_args.should == ["＠", "jacob", nil]
        @rewritten_text.should == "[rewritten]"
      end
    end
  end #}}}

  describe "rewrite lists" do #{{{
    before do
      @rewritten_text = Twitter::Rewriter.rewrite_usernames_or_lists(original_text, &method(:block))
    end

    context "slug preceded by a space" do
      def original_text; "hello @jacob/my-list"; end

      it "should be rewritten" do
        @block_args.should == ["@", "jacob", "/my-list"]
        @rewritten_text.should == "hello [rewritten]"
      end
    end

    context "username followed by a slash but no list" do
      def original_text; "hello @jacob/ my-list"; end

      it "should not be rewritten" do
        @block_args.should == ["@", "jacob", nil]
        @rewritten_text.should == "hello [rewritten]/ my-list"
      end
    end

    context "empty username followed by a list" do
      def original_text; "hello @/my-list"; end

      it "should not be rewritten" do
        @block_args.should be_nil
        @rewritten_text.should == "hello @/my-list"
      end
    end

    context "list slug at beginning of line" do
      def original_text; "@jacob/my-list"; end

      it "should be rewritten" do
        @block_args.should == ["@", "jacob", "/my-list"]
        @rewritten_text.should == "[rewritten]"
      end
    end

    context "username preceded by alpha-numeric character" do
      def original_text; "meet@jacob/my-list"; end

      it "should not be rewritten" do
        @block_args.should be_nil
        @rewritten_text.should == "meet@jacob/my-list"
      end
    end

    context "username preceded by non-word character" do
      def original_text; "great.@jacob/my-list"; end

      it "should be rewritten" do
        @block_args.should == ["@", "jacob", "/my-list"]
        @rewritten_text.should == "great.[rewritten]"
      end
    end

    context "username containing non-word characters" do
      def original_text; "@jacob/my-list&^$%^"; end

      it "should be rewritten" do
        @block_args.should == ["@", "jacob", "/my-list"]
        @rewritten_text.should == "[rewritten]&^$%^"
      end
    end

    context "username over twenty characters" do
      def original_text
        @twentyfive_character_list = "a" * 25
        "@jacob/#{@twentyfive_character_list}12345"
      end

      it "should be rewritten" do
        @block_args.should == ["@", "jacob", "/#{@twentyfive_character_list}"]
        @rewritten_text.should == "[rewritten]12345"
      end
    end
  end #}}}

  describe "rewrite hashtags" do #{{{
    before do
      @rewritten_text = Twitter::Rewriter.rewrite_hashtags(original_text, &method(:block))
    end

    context "with an all numeric hashtag" do
      def original_text; "#123"; end

      it "should not be rewritten" do
        @block_args.should be_nil
        @rewritten_text.should == "#123"
      end
    end

    context "with a hashtag with alphanumeric characters" do
      def original_text; "#ab1d"; end

      it "should be rewritten" do
        @block_args.should == ["#", "ab1d"]
        @rewritten_text.should == "[rewritten]"
      end
    end

    context "with a hashtag with underscores" do
      def original_text; "#a_b_c_d"; end

      it "should be rewritten" do
        @block_args.should == ["#", "a_b_c_d"]
        @rewritten_text.should == "[rewritten]"
      end
    end

    context "with a hashtag that is preceded by a word character" do
      def original_text; "ab#cd"; end

      it "should not be rewritten" do
        @block_args.should be_nil
        @rewritten_text.should == "ab#cd"
      end
    end

    context "with a hashtag that starts with a number but has word characters" do
      def original_text; "#2ab"; end

      it "should be rewritten" do
        @block_args.should == ["#", "2ab"]
        @rewritten_text.should == "[rewritten]"
      end
    end

    context "with multiple valid hashtags" do
      def original_text; "I'm frickin' awesome #ab #cd #ef"; end

      it "rewrites each hashtag" do
        @block_args.should == [["#", "ab"], ["#", "cd"], ["#", "ef"]]
        @rewritten_text.should == "I'm frickin' awesome [rewritten] [rewritten] [rewritten]"
      end
    end

    context "with a hashtag preceded by a ." do
      def original_text; "ok, great.#abc"; end

      it "should be rewritten" do
        @block_args.should == ["#", "abc"]
        @rewritten_text.should == "ok, great.[rewritten]"
      end
    end

    context "with a hashtag preceded by a &" do
      def original_text; "&#nbsp;"; end

      it "should not be rewritten" do
        @block_args.should be_nil
        @rewritten_text.should == "&#nbsp;"
      end
    end

    context "with a hashtag that ends in an !" do
      def original_text; "#great!"; end

      it "should be rewritten, but should not include the !" do
        @block_args.should == ["#", "great"];
        @rewritten_text.should == "[rewritten]!"
      end
    end

    context "with a hashtag followed by Japanese" do
      def original_text; "#twj_devの"; end

      it "should be rewritten" do
        @block_args.should == ["#", "twj_devの"];
        @rewritten_text.should == "[rewritten]"
      end
    end

    context "with a hashtag preceded by a full-width space" do
      def original_text; "#{[0x3000].pack('U')}#twj_dev"; end

      it "should be rewritten" do
        @block_args.should == ["#", "twj_dev"];
        @rewritten_text.should == "　[rewritten]"
      end
    end

    context "with a hashtag followed by a full-width space" do
      def original_text; "#twj_dev#{[0x3000].pack('U')}"; end

      it "should be rewritten" do
        @block_args.should == ["#", "twj_dev"];
        @rewritten_text.should == "[rewritten]　"
      end
    end

    context "with a hashtag using full-width hash" do
      def original_text; "#{[0xFF03].pack('U')}twj_dev"; end

      it "should be rewritten" do
        @block_args.should == ["＃", "twj_dev"];
        @rewritten_text.should == "[rewritten]"
      end
    end

    context "with a hashtag containing an accented latin character" do
      def original_text
        # the hashtag is #éhashtag
        "##{[0x00e9].pack('U')}hashtag"
      end

      it "should be rewritten" do
        @block_args.should == ["#", "éhashtag"];
        @rewritten_text.should == "[rewritten]"
      end
    end
  end #}}}

  describe "rewrite urls" do #{{{
    def url; "http://www.google.com"; end

    before do
      @rewritten_text = Twitter::Rewriter.rewrite_urls(original_text, &method(:block))
    end

    context "when embedded in plain text" do
      def original_text; "On my search engine #{url} I found good links."; end

      it "should be rewritten" do
        @block_args.should == [url];
        @rewritten_text.should == "On my search engine [rewritten] I found good links."
      end
    end

    context "when surrounded by Japanese;" do
      def original_text; "いまなにしてる#{url}いまなにしてる"; end

      it "should be rewritten" do
        @block_args.should == [url];
        @rewritten_text.should == "いまなにしてる[rewritten]いまなにしてる"
      end
    end

    context "with a path surrounded by parentheses;" do
      def original_text; "I found a neatness (#{url})"; end

      it "should be rewritten" do
        @block_args.should == [url];
        @rewritten_text.should == "I found a neatness ([rewritten])"
      end

      context "when the URL ends with a slash;" do
        def url; "http://www.google.com/"; end

        it "should be rewritten" do
          @block_args.should == [url];
          @rewritten_text.should == "I found a neatness ([rewritten])"
        end
      end

      context "when the URL has a path;" do
        def url; "http://www.google.com/fsdfasdf"; end

        it "should be rewritten" do
          @block_args.should == [url];
          @rewritten_text.should == "I found a neatness ([rewritten])"
        end
      end
    end

    context "when path contains parens" do
      def original_text; "I found a neatness (#{url})"; end

      it "should be rewritten" do
        @block_args.should == [url];
        @rewritten_text.should == "I found a neatness ([rewritten])"
      end

      context "wikipedia" do
        def url; "http://en.wikipedia.org/wiki/Madonna_(artist)"; end

        it "should be rewritten" do
          @block_args.should == [url];
          @rewritten_text.should == "I found a neatness ([rewritten])"
        end
      end

      context "IIS session" do
        def url; "http://msdn.com/S(deadbeef)/page.htm"; end

        it "should be rewritten" do
          @block_args.should == [url];
          @rewritten_text.should == "I found a neatness ([rewritten])"
        end
      end

      context "unbalanced parens" do
        def url; "http://example.com/i_has_a_("; end

        it "should be rewritten" do
          @block_args.should == ["http://example.com/i_has_a_"];
          @rewritten_text.should == "I found a neatness ([rewritten]()"
        end
      end

      context "balanced parens with a double quote inside" do
        def url; "http://foo.bar.com/foo_(\")_bar" end

        it "should be rewritten" do
          @block_args.should == ["http://foo.bar.com/foo_"];
          @rewritten_text.should == "I found a neatness ([rewritten](\")_bar)"
        end
      end

      context "balanced parens hiding XSS" do
        def url; 'http://x.xx.com/("style="color:red"onmouseover="alert(1)' end

        it "should be rewritten" do
          @block_args.should == ["http://x.xx.com/"];
          @rewritten_text.should == 'I found a neatness ([rewritten]("style="color:red"onmouseover="alert(1))'
        end
      end
    end

    context "when preceded by a :" do
      def original_text; "Check this out @hoverbird:#{url}"; end

      it "should be rewritten" do
        @block_args.should == [url];
        @rewritten_text.should == "Check this out @hoverbird:[rewritten]"
      end
    end

    context "with a URL ending in allowed punctuation" do
      it "does not consume ending punctuation" do
        %w| ? ! , . : ; ] ) } = \ ' |.each do |char|
          Twitter::Rewriter.rewrite_urls("#{url}#{char}") do |url|
            url.should == url; "[rewritten]"
          end.should == "[rewritten]#{char}"
        end
      end
    end

    context "with a URL preceded in forbidden characters" do
      it "should be rewritten" do
        %w| \ ' / ! = |.each do |char|
          Twitter::Rewriter.rewrite_urls("#{char}#{url}") do |url|
            "[rewritten]" # should not be called here.
          end.should == "#{char}[rewritten]"
        end
      end
    end

    context "when embedded in a link tag" do
      def original_text; "<link rel='true'>#{url}</link>"; end

      it "should be rewritten" do
        @block_args.should == [url];
        @rewritten_text.should == "<link rel='true'>[rewritten]</link>"
      end
    end

    context "with multiple URLs" do
      def original_text; "http://www.links.org link at start of page, link at end http://www.foo.org"; end

      it "should autolink each one" do
        @block_args.should == [["http://www.links.org"], ["http://www.foo.org"]];
        @rewritten_text.should == "[rewritten] link at start of page, link at end [rewritten]"
      end
    end

    context "with multiple URLs in different formats" do
      def original_text; "http://foo.com https://bar.com http://mail.foobar.org"; end

      it "should autolink each one, in the proper order" do
        @block_args.should == [["http://foo.com"], ["https://bar.com"], ["http://mail.foobar.org"]];
        @rewritten_text.should == "[rewritten] [rewritten] [rewritten]"
      end
    end

    context "with a URL having a long TLD" do
      def original_text; "Yahoo integriert Facebook http://golem.mobi/0912/71607.html"; end

      it "should autolink it" do
        @block_args.should == ["http://golem.mobi/0912/71607.html"]
        @rewritten_text.should == "Yahoo integriert Facebook [rewritten]"
      end
    end

    context "with a url lacking the protocol" do
      def original_text; "I like www.foobar.com dudes"; end

      it "does not link at all" do
        @block_args.should be_nil
        @rewritten_text.should == "I like www.foobar.com dudes"
      end
    end

    context "with a @ in a URL" do
      context "with XSS attack" do
        def original_text; 'http://x.xx.com/@"style="color:pink"onmouseover=alert(1)//'; end

        it "should not allow XSS follwing @" do
          @block_args.should == ["http://x.xx.com/"]
          @rewritten_text.should == '[rewritten]@"style="color:pink"onmouseover=alert(1)//'
        end
      end

      context "with a username not followed by a /" do
        def original_text; "http://example.com/@foobar"; end

        it "should link url" do
          @block_args.should == ["http://example.com/@foobar"]
          @rewritten_text.should == "[rewritten]"
        end
      end

      context "with a username followed by a /" do
        def original_text; "http://example.com/@foobar/"; end

        it "should not link the username but link full url" do
          @block_args.should == ["http://example.com/@foobar/"]
          @rewritten_text.should == "[rewritten]"
        end
      end
    end
  end #}}}
end

# vim: foldmethod=marker
