# encoding: utf-8
require File.dirname(__FILE__) + '/spec_helper'

class TestExtractor
  include Twitter::Extractor
end

describe Twitter::Extractor do
  before do
    @extractor = TestExtractor.new
  end

  describe "mentions" do
    context "single screen name alone " do
      it "should be linked" do
        @extractor.extract_mentioned_screen_names("@alice").should == ["alice"]
      end

      it "should be linked with _" do
        @extractor.extract_mentioned_screen_names("@alice_adams").should == ["alice_adams"]
      end

      it "should be linked if numeric" do
        @extractor.extract_mentioned_screen_names("@1234").should == ["1234"]
      end
    end

    context "multiple screen names" do
      it "should both be linked" do
        @extractor.extract_mentioned_screen_names("@alice @bob").should == ["alice", "bob"]
      end
    end

    context "screen names embedded in text" do
      it "should be linked in Latin text" do
        @extractor.extract_mentioned_screen_names("waiting for @alice to arrive").should == ["alice"]
      end

      it "should be linked in Japanese text" do
        @extractor.extract_mentioned_screen_names("の@aliceに到着を待っている").should == ["alice"]
      end

      it "should ignore mentions preceded by !, @, #, $, %, & or *" do
        invalid_chars = ['!', '@', '#', '$', '%', '&', '*']
        invalid_chars.each do |c|
          @extractor.extract_mentioned_screen_names("f#{c}@kn").should == []
        end
      end
    end

    it "should accept a block arugment and call it in order" do
      needed = ["alice", "bob"]
      @extractor.extract_mentioned_screen_names("@alice @bob") do |sn|
        sn.should == needed.shift
      end
      needed.should == []
    end
  end

  describe "mentions with indices" do
    context "single screen name alone " do
      it "should be linked and the correct indices" do
        @extractor.extract_mentioned_screen_names_with_indices("@alice").should == [{:screen_name => "alice", :indices => [0, 6]}]
      end

      it "should be linked with _ and the correct indices" do
        @extractor.extract_mentioned_screen_names_with_indices("@alice_adams").should == [{:screen_name => "alice_adams", :indices => [0, 12]}]
      end

      it "should be linked if numeric and the correct indices" do
        @extractor.extract_mentioned_screen_names_with_indices("@1234").should == [{:screen_name => "1234", :indices => [0, 5]}]
      end
    end

    context "multiple screen names" do
      it "should both be linked with the correct indices" do
        @extractor.extract_mentioned_screen_names_with_indices("@alice @bob").should ==
          [{:screen_name => "alice", :indices => [0, 6]},
           {:screen_name => "bob", :indices => [7, 11]}]
      end

      it "should be linked with the correct indices even when repeated" do
        @extractor.extract_mentioned_screen_names_with_indices("@alice @alice @bob").should ==
          [{:screen_name => "alice", :indices => [0, 6]},
           {:screen_name => "alice", :indices => [7, 13]},
           {:screen_name => "bob", :indices => [14, 18]}]
      end
    end

    context "screen names embedded in text" do
      it "should be linked in Latin text with the correct indices" do
        @extractor.extract_mentioned_screen_names_with_indices("waiting for @alice to arrive").should == [{:screen_name => "alice", :indices => [12, 18]}]
      end

      it "should be linked in Japanese text with the correct indices" do
        @extractor.extract_mentioned_screen_names_with_indices("の@aliceに到着を待っている").should == [{:screen_name => "alice", :indices => [1, 7]}]
      end
    end

    it "should accept a block arugment and call it in order" do
      needed = [{:screen_name => "alice", :indices => [0, 6]}, {:screen_name => "bob", :indices => [7, 11]}]
      @extractor.extract_mentioned_screen_names_with_indices("@alice @bob") do |sn, start_index, end_index|
        data = needed.shift
        sn.should == data[:screen_name]
        start_index.should == data[:indices].first
        end_index.should == data[:indices].last
      end
      needed.should == []
    end

    it "should extract screen name in text with supplementary character" do
      @extractor.extract_mentioned_screen_names_with_indices("#{[0x10400].pack('U')} @alice").should == [{:screen_name => "alice", :indices => [2, 8]}]
    end
  end

  describe "replies" do
    context "should be extracted from" do
      it "should extract from lone name" do
        @extractor.extract_reply_screen_name("@alice").should == "alice"
      end

      it "should extract from the start" do
        @extractor.extract_reply_screen_name("@alice reply text").should == "alice"
      end

      it "should extract preceded by a space" do
        @extractor.extract_reply_screen_name(" @alice reply text").should == "alice"
      end

      it "should extract preceded by a full-width space" do
        @extractor.extract_reply_screen_name("#{[0x3000].pack('U')}@alice reply text").should == "alice"
      end
    end

    context "should not be extracted from" do
      it "should not be extracted when preceded by text" do
        @extractor.extract_reply_screen_name("reply @alice text").should == nil
      end

      it "should not be extracted when preceded by puctuation" do
        %w(. / _ - + # ! @).each do |punct|
          @extractor.extract_reply_screen_name("#{punct}@alice text").should == nil
        end
      end
    end

    context "should accept a block arugment" do
      it "should call the block on match" do
        @extractor.extract_reply_screen_name("@alice") do |sn|
          sn.should == "alice"
        end
      end

      it "should not call the block on no match" do
        calls = 0
        @extractor.extract_reply_screen_name("not a reply") do |sn|
          calls += 1
        end
        calls.should == 0
      end
    end
  end

  describe "urls" do
    describe "matching URLS" do
      TestUrls::VALID.each do |url|
        it "should extract the URL #{url} and prefix it with a protocol if missing" do
          @extractor.extract_urls(url).first.should include(url)
        end

        it "should match the URL #{url} when it's embedded in other text" do
          text = "Sweet url: #{url} I found. #awesome"
          @extractor.extract_urls(text).first.should include(url)
        end
      end
    end

    describe "invalid URLS" do
      it "does not link urls with invalid domains" do
        @extractor.extract_urls("http://tld-too-short.x").should == []
      end
    end

    describe "t.co URLS" do
      TestUrls::TCO.each do |url|
        it "should only extract the t.co URL from the URL #{url}" do
          extracted_urls = @extractor.extract_urls(url)
          extracted_urls.size.should == 1
          extracted_url = extracted_urls.first
          extracted_url.should_not == url
          extracted_url.should == url[0...20]
        end

        it "should match the t.co URL from the URL #{url} when it's embedded in other text" do
          text = "Sweet url: #{url} I found. #awesome"
          extracted_urls = @extractor.extract_urls(text)
          extracted_urls.size.should == 1
          extracted_url = extracted_urls.first
          extracted_url.should_not == url
          extracted_url.should == url[0...20]
        end
      end
    end
  end

  describe "urls with indices" do
    describe "matching URLS" do
      TestUrls::VALID.each do |url|
        it "should extract the URL #{url} and prefix it with a protocol if missing" do
          extracted_urls = @extractor.extract_urls_with_indices(url)
          extracted_urls.size.should == 1
          extracted_url = extracted_urls.first
          extracted_url[:url].should include(url)
          extracted_url[:indices].first.should == 0
          extracted_url[:indices].last.should == url.chars.to_a.size
        end

        it "should match the URL #{url} when it's embedded in other text" do
          text = "Sweet url: #{url} I found. #awesome"
          extracted_urls = @extractor.extract_urls_with_indices(text)
          extracted_urls.size.should == 1
          extracted_url = extracted_urls.first
          extracted_url[:url].should include(url)
          extracted_url[:indices].first.should == 11
          extracted_url[:indices].last.should == 11 + url.chars.to_a.size
        end
      end

      it "should extract URL in text with supplementary character" do
        @extractor.extract_urls_with_indices("#{[0x10400].pack('U')} http://twitter.com").should == [{:url => "http://twitter.com", :indices => [2, 20]}]
      end
    end

    describe "invalid URLS" do
      it "does not link urls with invalid domains" do
        @extractor.extract_urls_with_indices("http://tld-too-short.x").should == []
      end
    end

    describe "t.co URLS" do
      TestUrls::TCO.each do |url|
        it "should only extract the t.co URL from the URL #{url} and adjust indices correctly" do
          extracted_urls = @extractor.extract_urls_with_indices(url)
          extracted_urls.size.should == 1
          extracted_url = extracted_urls.first
          extracted_url[:url].should_not include(url)
          extracted_url[:url].should include(url[0...20])
          extracted_url[:indices].first.should == 0
          extracted_url[:indices].last.should == 20
        end

        it "should match the t.co URL from the URL #{url} when it's embedded in other text" do
          text = "Sweet url: #{url} I found. #awesome"
          extracted_urls = @extractor.extract_urls_with_indices(text)
          extracted_urls.size.should == 1
          extracted_url = extracted_urls.first
          extracted_url[:url].should_not include(url)
          extracted_url[:url].should include(url[0...20])
          extracted_url[:indices].first.should == 11
          extracted_url[:indices].last.should == 31
        end
      end
    end
  end

  describe "hashtags" do
    context "extracts latin/numeric hashtags" do
      %w(text text123 123text).each do |hashtag|
        it "should extract ##{hashtag}" do
          @extractor.extract_hashtags("##{hashtag}").should == [hashtag]
        end

        it "should extract ##{hashtag} within text" do
          @extractor.extract_hashtags("pre-text ##{hashtag} post-text").should == [hashtag]
        end
      end
    end

    context "international hashtags" do
      context "should allow accents" do
        %w(mañana café münchen).each do |hashtag|
          it "should extract ##{hashtag}" do
            @extractor.extract_hashtags("##{hashtag}").should == [hashtag]
          end

          it "should extract ##{hashtag} within text" do
            @extractor.extract_hashtags("pre-text ##{hashtag} post-text").should == [hashtag]
          end
        end

        it "should not allow the multiplication character" do
          @extractor.extract_hashtags("#pre#{Twitter::Unicode::U00D7}post").should == ["pre"]
        end

        it "should not allow the division character" do
          @extractor.extract_hashtags("#pre#{Twitter::Unicode::U00F7}post").should == ["pre"]
        end
      end

    end

    it "should not extract numeric hashtags" do
      @extractor.extract_hashtags("#1234").should == []
    end

    it "should extract hashtag followed by punctuations" do
      @extractor.extract_hashtags("#test1: #test2; #test3\"").should == ["test1", "test2" ,"test3"]
    end
  end

  describe "hashtags with indices" do
    def match_hashtag_in_text(hashtag, text, offset = 0)
      extracted_hashtags = @extractor.extract_hashtags_with_indices(text)
      extracted_hashtags.size.should == 1
      extracted_hashtag = extracted_hashtags.first
      extracted_hashtag[:hashtag].should == hashtag
      extracted_hashtag[:indices].first.should == offset
      extracted_hashtag[:indices].last.should == offset + hashtag.chars.to_a.size + 1
    end

    def not_match_hashtag_in_text(text)
      extracted_hashtags = @extractor.extract_hashtags_with_indices(text)
      extracted_hashtags.size.should == 0
    end

    context "extracts latin/numeric hashtags" do
      %w(text text123 123text).each do |hashtag|
        it "should extract ##{hashtag}" do
          match_hashtag_in_text(hashtag, "##{hashtag}")
        end

        it "should extract ##{hashtag} within text" do
          match_hashtag_in_text(hashtag, "pre-text ##{hashtag} post-text", 9)
        end
      end
    end

    context "international hashtags" do
      context "should allow accents" do
        %w(mañana café münchen).each do |hashtag|
          it "should extract ##{hashtag}" do
            match_hashtag_in_text(hashtag, "##{hashtag}")
          end

          it "should extract ##{hashtag} within text" do
            match_hashtag_in_text(hashtag, "pre-text ##{hashtag} post-text", 9)
          end
        end

        it "should not allow the multiplication character" do
          match_hashtag_in_text("pre", "#pre#{[0xd7].pack('U')}post", 0)
        end

        it "should not allow the division character" do
          match_hashtag_in_text("pre", "#pre#{[0xf7].pack('U')}post", 0)
        end
      end
    end

    it "should not extract numeric hashtags" do
      not_match_hashtag_in_text("#1234")
    end

    it "should extract hashtag in text with supplementary character" do
      match_hashtag_in_text("hashtag", "#{[0x10400].pack('U')} #hashtag", 2)
    end
  end
end
