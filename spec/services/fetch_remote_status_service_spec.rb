require 'rails_helper'

RSpec.describe FetchRemoteStatusService, type: :service do
  let(:account) { Fabricate(:account) }
  let(:prefetched_body) { nil }
  let(:valid_domain) { Rails.configuration.x.local_domain }

  let(:note) do
    {
      '@context': 'https://www.w3.org/ns/activitystreams',
      id: "https://#{valid_domain}/@foo/1234",
      type: 'Note',
      content: 'Lorem ipsum',
      attributedTo: ActivityPub::TagManager.instance.uri_for(account),
    }
  end

  context 'protocol is :activitypub' do
    subject { described_class.new.call(note[:id], prefetched_body, protocol) }
    let(:prefetched_body) { Oj.dump(note) }
    let(:protocol) { :activitypub }

    before do
      account.update(uri: ActivityPub::TagManager.instance.uri_for(account))
      subject
    end

    it 'creates status' do
      status = account.statuses.first

      expect(status).to_not be_nil
      expect(status.text).to eq 'Lorem ipsum'
    end
  end

  context 'protocol is :ostatus' do
    subject { described_class.new }

    before do
      Fabricate(:account, username: 'tracer', domain: 'real.domain', remote_url: 'https://real.domain/users/tracer')
    end

    it 'does not create status with author at different domain' do
      status_body = <<-XML.squish
        <?xml version="1.0"?>
        <entry xmlns="http://www.w3.org/2005/Atom" xmlns:thr="http://purl.org/syndication/thread/1.0" xmlns:activity="http://activitystrea.ms/spec/1.0/" xmlns:poco="http://portablecontacts.net/spec/1.0" xmlns:media="http://purl.org/syndication/atommedia" xmlns:ostatus="http://ostatus.org/schema/1.0" xmlns:mastodon="http://mastodon.social/schema/1.0">
          <id>tag:real.domain,2017-04-27:objectId=4487555:objectType=Status</id>
          <published>2017-04-27T13:49:25Z</published>
          <updated>2017-04-27T13:49:25Z</updated>
          <activity:object-type>http://activitystrea.ms/schema/1.0/note</activity:object-type>
          <activity:verb>http://activitystrea.ms/schema/1.0/post</activity:verb>
          <author>
            <id>https://real.domain/users/tracer</id>
            <activity:object-type>http://activitystrea.ms/schema/1.0/person</activity:object-type>
            <uri>https://real.domain/users/tracer</uri>
            <name>tracer</name>
          </author>
          <content type="html">Overwatch rocks</content>
        </entry>
      XML

      expect(subject.call('https://fake.domain/foo', status_body, :ostatus)).to be_nil
    end

    it 'does not create status with wrong id when id uses http format' do
      status_body = <<-XML.squish
        <?xml version="1.0"?>
        <entry xmlns="http://www.w3.org/2005/Atom" xmlns:thr="http://purl.org/syndication/thread/1.0" xmlns:activity="http://activitystrea.ms/spec/1.0/" xmlns:poco="http://portablecontacts.net/spec/1.0" xmlns:media="http://purl.org/syndication/atommedia" xmlns:ostatus="http://ostatus.org/schema/1.0" xmlns:mastodon="http://mastodon.social/schema/1.0">
          <id>https://other-real.domain/statuses/123</id>
          <published>2017-04-27T13:49:25Z</published>
          <updated>2017-04-27T13:49:25Z</updated>
          <activity:object-type>http://activitystrea.ms/schema/1.0/note</activity:object-type>
          <activity:verb>http://activitystrea.ms/schema/1.0/post</activity:verb>
          <author>
            <id>https://real.domain/users/tracer</id>
            <activity:object-type>http://activitystrea.ms/schema/1.0/person</activity:object-type>
            <uri>https://real.domain/users/tracer</uri>
            <name>tracer</name>
          </author>
          <content type="html">Overwatch rocks</content>
        </entry>
      XML

      expect(subject.call('https://real.domain/statuses/456', status_body, :ostatus)).to be_nil
    end
  end
end
