# frozen_string_literal: true

# rubocop:disable Lint/Void, Metrics/BlockLength

# Adopted rb/lib/twitter-text/extractor.rb from twitter-text.
# Please contribute new changes of this file to the upstream if they are not specific to Mastodon.

require 'rails_helper'
require 'text_helper'

describe Extractor do
  describe 'mentions' do
    context 'single screen name alone ' do
      it 'should be linked' do
        Extractor.extract_mentions('@alice').should == ['alice']
      end

      it 'should be linked with _' do
        Extractor.extract_mentions('@alice_adams').should == ['alice_adams']
      end

      it 'should be linked if numeric' do
        Extractor.extract_mentions('@1234').should == ['1234']
      end
    end

    context 'multiple screen names' do
      it 'should both be linked' do
        Extractor.extract_mentions('@alice @bob').should == %w(alice bob)
      end
    end

    context 'screen names embedded in text' do
      it 'should be linked in Latin text' do
        Extractor.extract_mentions('waiting for @alice to arrive').should == ['alice']
      end
    end

    it 'should accept a block arugment and call it in order' do
      needed = %w(alice bob)
      Extractor.extract_mentions('@alice @bob') do |sn|
        sn.should == needed.shift
      end
      needed.should == []
    end
  end

  describe 'mentions with indices' do
    context 'single screen name alone ' do
      it 'should be linked and the correct indices' do
        Extractor.extract_mentions_with_indices('@alice').should == [{ screen_name: 'alice', indices: [0, 6] }]
      end

      it 'should be linked with _ and the correct indices' do
        Extractor.extract_mentions_with_indices('@alice_adams').should == [{ screen_name: 'alice_adams', indices: [0, 12] }]
      end

      it 'should be linked if numeric and the correct indices' do
        Extractor.extract_mentions_with_indices('@1234').should == [{ screen_name: '1234', indices: [0, 5] }]
      end
    end

    context 'multiple screen names' do
      it 'should both be linked with the correct indices' do
        Extractor.extract_mentions_with_indices('@alice @bob').should ==
          [{ screen_name: 'alice', indices: [0, 6] },
           { screen_name: 'bob', indices: [7, 11] }]
      end

      it 'should be linked with the correct indices even when repeated' do
        Extractor.extract_mentions_with_indices('@alice @alice @bob').should ==
          [{ screen_name: 'alice', indices: [0, 6] },
           { screen_name: 'alice', indices: [7, 13] },
           { screen_name: 'bob', indices: [14, 18] }]
      end
    end

    context 'screen names embedded in text' do
      it 'should be linked in Latin text with the correct indices' do
        Extractor.extract_mentions_with_indices('waiting for @alice to arrive').should == [{ screen_name: 'alice', indices: [12, 18] }]
      end
    end

    it 'should accept a block arugment and call it in order' do
      needed = [{ screen_name: 'alice', indices: [0, 6] }, { screen_name: 'bob', indices: [7, 11] }]
      Extractor.extract_mentions_with_indices('@alice @bob') do |sn, start_index, end_index|
        data = needed.shift
        sn.should == data[:screen_name]
        start_index.should == data[:indices].first
        end_index.should == data[:indices].last
      end
      needed.should == []
    end

    it 'should extract screen name in text with supplementary character' do
      Extractor.extract_mentions_with_indices("#{[0x10400].pack('U')} @alice").should == [{ screen_name: 'alice', indices: [2, 8] }]
    end
  end

  describe 'urls' do
    describe 'matching URLS' do
      TestUrls::VALID.each do |url|
        it "should extract the URL #{url} and prefix it with a protocol if missing" do
          Extractor.extract_urls(url).first.should include(url)
        end

        it "should match the URL #{url} when it's embedded in other text" do
          text = "Sweet url: #{url} I found. #awesome"
          Extractor.extract_urls(text).first.should include(url)
        end
      end
    end

    describe 'invalid URLS' do
      it 'does not link urls with invalid domains' do
        Extractor.extract_urls('http://tld-too-short.x').should == []
      end
    end
  end

  describe 'urls with indices' do
    describe 'matching URLS' do
      TestUrls::VALID.each do |url|
        it "should extract the URL #{url} and prefix it with a protocol if missing" do
          extracted_urls = Extractor.extract_urls_with_indices(url)
          extracted_urls.size.should == 1
          extracted_url = extracted_urls.first
          extracted_url[:url].should include(url)
          extracted_url[:indices].first.should == 0
          extracted_url[:indices].last.should == url.chars.to_a.size
        end

        it "should match the URL #{url} when it's embedded in other text" do
          text = "Sweet url: #{url} I found. #awesome"
          extracted_urls = Extractor.extract_urls_with_indices(text)
          extracted_urls.size.should == 1
          extracted_url = extracted_urls.first
          extracted_url[:url].should include(url)
          extracted_url[:indices].first.should == 11
          extracted_url[:indices].last.should == 11 + url.chars.to_a.size
        end
      end

      it 'should extract URL in text with supplementary character' do
        Extractor.extract_urls_with_indices("#{[0x10400].pack('U')} http://twitter.com").should == [{ url: 'http://twitter.com', indices: [2, 20] }]
      end
    end

    describe 'invalid URLS' do
      it 'does not link urls with invalid domains' do
        Extractor.extract_urls_with_indices('http://tld-too-short.x').should == []
      end
    end
  end

  describe 'hashtags' do
    context 'extracts latin/numeric hashtags' do
      %w(text text123 123text).each do |hashtag|
        it "should extract ##{hashtag}" do
          Extractor.extract_hashtags("##{hashtag}").should == [hashtag]
        end

        it "should extract ##{hashtag} within text" do
          Extractor.extract_hashtags("pre-text ##{hashtag} post-text").should == [hashtag]
        end
      end
    end

    context 'international hashtags' do
      context 'should allow accents' do
        %w(mañana café münchen).each do |hashtag|
          it "should extract ##{hashtag}" do
            Extractor.extract_hashtags("##{hashtag}").should == [hashtag]
          end

          it "should extract ##{hashtag} within text" do
            Extractor.extract_hashtags("pre-text ##{hashtag} post-text").should == [hashtag]
          end
        end

        it 'should not allow the multiplication character' do
          Extractor.extract_hashtags("#pre#{[0xD7].pack('U')}post").should == ['pre']
        end

        it 'should not allow the division character' do
          Extractor.extract_hashtags("#pre#{[0xF7].pack('U')}post").should == ['pre']
        end
      end
    end

    it 'should not extract numeric hashtags' do
      Extractor.extract_hashtags('#1234').should == []
    end

    it 'should extract hashtag followed by punctuations' do
      Extractor.extract_hashtags('#test1: #test2; #test3"').should == %w(test1 test2 test3)
    end
  end

  describe 'hashtags with indices' do
    def match_hashtag_in_text(hashtag, text, offset = 0)
      extracted_hashtags = Extractor.extract_hashtags_with_indices(text)
      extracted_hashtags.size.should == 1
      extracted_hashtag = extracted_hashtags.first
      extracted_hashtag[:hashtag].should == hashtag
      extracted_hashtag[:indices].first.should == offset
      extracted_hashtag[:indices].last.should == offset + hashtag.chars.to_a.size + 1
    end

    def not_match_hashtag_in_text(text)
      extracted_hashtags = Extractor.extract_hashtags_with_indices(text)
      extracted_hashtags.size.should == 0
    end

    context 'extracts latin/numeric hashtags' do
      %w(text text123 123text).each do |hashtag|
        it "should extract ##{hashtag}" do
          match_hashtag_in_text(hashtag, "##{hashtag}")
        end

        it "should extract ##{hashtag} within text" do
          match_hashtag_in_text(hashtag, "pre-text ##{hashtag} post-text", 9)
        end
      end
    end

    context 'international hashtags' do
      context 'should allow accents' do
        %w(mañana café münchen).each do |hashtag|
          it "should extract ##{hashtag}" do
            match_hashtag_in_text(hashtag, "##{hashtag}")
          end

          it "should extract ##{hashtag} within text" do
            match_hashtag_in_text(hashtag, "pre-text ##{hashtag} post-text", 9)
          end
        end

        it 'should not allow the multiplication character' do
          match_hashtag_in_text('pre', "#pre#{[0xd7].pack('U')}post", 0)
        end

        it 'should not allow the division character' do
          match_hashtag_in_text('pre', "#pre#{[0xf7].pack('U')}post", 0)
        end
      end
    end

    it 'should not extract numeric hashtags' do
      not_match_hashtag_in_text('#1234')
    end

    it 'should extract hashtag in text with supplementary character' do
      match_hashtag_in_text('hashtag', "#{[0x10400].pack('U')} #hashtag", 2)
    end
  end

  describe 'Mastodon modifications' do
    context 'mentions' do
      context 'screen names embedded in text' do
        it 'should not be linked in Japanese text' do
          Extractor.extract_mentions('の@aliceに到着を待っている').should == []
        end

        it 'should not ignore mentions preceded by !, @, #, $, %, & or *' do
          chars = ['!', '@', '#', '$', '%', '&', '*']
          chars.each do |c|
            Extractor.extract_mentions("f#{c}@kn").should == ["kn"]
          end
        end
      end
    end
  end
end
