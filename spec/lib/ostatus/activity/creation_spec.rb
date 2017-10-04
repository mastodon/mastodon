# frozen_string_literal: true

require 'rails_helper'

describe OStatus::Activity::Creation do
  subject do
    class C < OStatus::Activity::Creation
      def reblog
        nil
      end
    end

    C
  end

  describe '#perform' do
    def stub_emoji_request_success
      stub_request(:get, 'https://kickass.zone/system/custom_emoji_icons/images/emojo.png').to_return body: attachment_fixture('emojo.png')
      stub_request(:get, 'https://kickass.zone/emojis/1').to_return headers: { 'Content-Type': 'application/activity+json' }, body: <<~JSON
        {
          "@context": "https://www.w3.org/ns/activitystreams",
          "id": "https://kickass.zone/emojis/1",
          "type": "Image",
          "url": "https://kickass.zone/system/custom_emoji_icons/images/emojo.png"
        }
      JSON
    end

    def stub_emoji_request_error
      stub_request(:get, 'https://kickass.zone/emojis/1').to_return status: 400
    end

    it 'does not perform if account is suspended'
    it 'performs via ActivityPub if it contains ActivityPub URI and the visibility is public'
    it 'returns an existing status with the same ID if any'
    it 'saves status'
    it 'saves mentions'
    it 'saves hashtags'
    it 'saves media'

    it 'does not raise even if href of emoji is missing' do
      account = Fabricate(:account, suspended: false)

      xml = Nokogiri::XML(<<~XML)
        <?xml version="1.0"?>
        <entry xmlns="http://www.w3.org/2005/Atom" xmlns:activity="http://activitystrea.ms/spec/1.0/">
          <id>tag:kickass.zone,2016-10-10:objectId=17:objectType=Status</id>
          <published>2016-10-10T00:41:31Z</published>
          <content type="html">&lt;p&gt;Social media needs MOAR cats! :manekineko:</content>
          <activity:verb>http://activitystrea.ms/schema/1.0/post</activity:verb>
          <activity:object-type>http://activitystrea.ms/schema/1.0/note</activity:object-type>
          <link name="manekineko" rel="emoji"/>
        </entry>
      XML

      subject.new(xml.at_xpath('//xmlns:entry', xmlns: OStatus::TagManager::XMLNS), account).perform
    end

    it 'does not raise even if name of emoji is missing' do
      stub_emoji_request_success
      account = Fabricate(:account, suspended: false)

      xml = Nokogiri::XML(<<~XML)
        <?xml version="1.0"?>
        <entry xmlns="http://www.w3.org/2005/Atom" xmlns:activity="http://activitystrea.ms/spec/1.0/">
          <id>tag:kickass.zone,2016-10-10:objectId=17:objectType=Status</id>
          <published>2016-10-10T00:41:31Z</published>
          <content type="html">&lt;p&gt;Social media needs MOAR cats! :manekineko:</content>
          <activity:verb>http://activitystrea.ms/schema/1.0/post</activity:verb>
          <activity:object-type>http://activitystrea.ms/schema/1.0/note</activity:object-type>
          <link href="https://kickass.zone/emojis/1" rel="emoji"/>
        </entry>
      XML

      subject.new(xml.at_xpath('//xmlns:entry', xmlns: OStatus::TagManager::XMLNS), account).perform
    end

    it 'does not raise even if custom emoji already exists' do
      stub_emoji_request_success
      Fabricate(:custom_emoji, domain: 'kickass.zone', shortcode: 'manekineko')
      account = Fabricate(:account, suspended: false)

      xml = Nokogiri::XML(<<~XML)
        <?xml version="1.0"?>
        <entry xmlns="http://www.w3.org/2005/Atom" xmlns:activity="http://activitystrea.ms/spec/1.0/">
          <id>tag:kickass.zone,2016-10-10:objectId=17:objectType=Status</id>
          <published>2016-10-10T00:41:31Z</published>
          <content type="html">&lt;p&gt;Social media needs MOAR cats! :manekineko:</content>
          <activity:verb>http://activitystrea.ms/schema/1.0/post</activity:verb>
          <activity:object-type>http://activitystrea.ms/schema/1.0/note</activity:object-type>
          <link href="https://kickass.zone/emojis/1" name="manekineko" rel="emoji"/>
        </entry>
      XML

      subject.new(xml.at_xpath('//xmlns:entry', xmlns: OStatus::TagManager::XMLNS), account).perform
    end

    context 'when custom emoji icon already exists' do
      it 'does not raise' do
        stub_emoji_request_success
        Fabricate(:custom_emoji_icon, uri: 'https://kickass.zone/emojis/1')
        account = Fabricate(:account, suspended: false)

        xml = Nokogiri::XML(<<~XML)
          <?xml version="1.0"?>
          <entry xmlns="http://www.w3.org/2005/Atom" xmlns:activity="http://activitystrea.ms/spec/1.0/">
            <id>tag:kickass.zone,2016-10-10:objectId=17:objectType=Status</id>
            <published>2016-10-10T00:41:31Z</published>
            <content type="html">&lt;p&gt;Social media needs MOAR cats! :manekineko:</content>
            <activity:verb>http://activitystrea.ms/schema/1.0/post</activity:verb>
            <activity:object-type>http://activitystrea.ms/schema/1.0/note</activity:object-type>
            <link href="https://kickass.zone/emojis/1" name="manekineko" rel="emoji"/>
          </entry>
        XML

        subject.new(xml.at_xpath('//xmlns:entry', xmlns: OStatus::TagManager::XMLNS), account).perform
      end
    end

    context 'when custom emoji icon does not exist' do
      it 'does not fetch custom emoji icon if domain is blocked' do
        stub_emoji_request_success
        Fabricate(:domain_block, domain: 'kickass.zone', reject_media: true)
        account = Fabricate(:account, suspended: false)

        xml = Nokogiri::XML(<<~XML)
          <?xml version="1.0"?>
          <entry xmlns="http://www.w3.org/2005/Atom" xmlns:activity="http://activitystrea.ms/spec/1.0/">
            <id>tag:kickass.zone,2016-10-10:objectId=17:objectType=Status</id>
            <published>2016-10-10T00:41:31Z</published>
            <content type="html">&lt;p&gt;Social media needs MOAR cats! :manekineko:</content>
            <activity:verb>http://activitystrea.ms/schema/1.0/post</activity:verb>
            <activity:object-type>http://activitystrea.ms/schema/1.0/note</activity:object-type>
            <link href="https://kickass.zone/emojis/1" name="manekineko" rel="emoji"/>
          </entry>
        XML

        subject.new(xml.at_xpath('//xmlns:entry', xmlns: OStatus::TagManager::XMLNS), account).perform

        expect(CustomEmojiIcon.where(uri: 'https://kickass.zone/emojis/1')).not_to exist
      end

      it 'fetches custom emoji icon' do
        stub_emoji_request_success
        account = Fabricate(:account, suspended: false)

        xml = Nokogiri::XML(<<~XML)
          <?xml version="1.0"?>
          <entry xmlns="http://www.w3.org/2005/Atom" xmlns:activity="http://activitystrea.ms/spec/1.0/">
            <id>tag:kickass.zone,2016-10-10:objectId=17:objectType=Status</id>
            <published>2016-10-10T00:41:31Z</published>
            <content type="html">&lt;p&gt;Social media needs MOAR cats! :manekineko:</content>
            <activity:verb>http://activitystrea.ms/schema/1.0/post</activity:verb>
            <activity:object-type>http://activitystrea.ms/schema/1.0/note</activity:object-type>
            <link href="https://kickass.zone/emojis/1" name="manekineko" rel="emoji"/>
          </entry>
        XML

        subject.new(xml.at_xpath('//xmlns:entry', xmlns: OStatus::TagManager::XMLNS), account).perform

        expect(CustomEmojiIcon.where(uri: 'https://kickass.zone/emojis/1', image_remote_url: 'https://kickass.zone/system/custom_emoji_icons/images/emojo.png')).to exist
      end

      it 'does not raise even if custom emoji icon cannot be fetched' do
        stub_emoji_request_error
        account = Fabricate(:account, suspended: false)

        xml = Nokogiri::XML(<<~XML)
          <?xml version="1.0"?>
          <entry xmlns="http://www.w3.org/2005/Atom" xmlns:activity="http://activitystrea.ms/spec/1.0/">
            <id>tag:kickass.zone,2016-10-10:objectId=17:objectType=Status</id>
            <published>2016-10-10T00:41:31Z</published>
            <content type="html">&lt;p&gt;Social media needs MOAR cats! :manekineko:</content>
            <activity:verb>http://activitystrea.ms/schema/1.0/post</activity:verb>
            <activity:object-type>http://activitystrea.ms/schema/1.0/note</activity:object-type>
            <link href="https://kickass.zone/emojis/1" name="manekineko" rel="emoji"/>
          </entry>
        XML

        expect { subject.new(xml.at_xpath('//xmlns:entry', xmlns: OStatus::TagManager::XMLNS), account).perform }.not_to raise_error
      end
    end

    it 'saves emojis'
  end
end
