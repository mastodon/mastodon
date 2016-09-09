require 'rails_helper'

RSpec.describe AtomBuilderHelper, type: :helper do
  describe '#stream_updated_at' do
    pending
  end

  describe '#entry' do
    it 'creates an entry' do
      expect(used_in_builder { |xml| helper.entry(xml) }).to match '<entry/>'
    end
  end

  describe '#feed' do
    it 'creates a feed' do
      expect(used_in_builder { |xml| helper.feed(xml) }).to match '<feed xmlns="http://www.w3.org/2005/Atom" xmlns:thr="http://purl.org/syndication/thread/1.0" xmlns:activity="http://activitystrea.ms/spec/1.0/" xmlns:poco="http://portablecontacts.net/spec/1.0" xmlns:media="http://purl.org/syndication/atommedia"/>'
    end
  end

  describe '#unique_id' do
    it 'creates an id' do
      time = Time.now
      expect(used_in_builder { |xml| helper.unique_id(xml, time, 1, 'Status') }).to match "<id>#{TagManager.instance.unique_tag(time, 1, 'Status')}</id>"
    end
  end

  describe '#simple_id' do
    it 'creates an id' do
      expect(used_in_builder { |xml| helper.simple_id(xml, 1) }).to match '<id>1</id>'
    end
  end

  describe '#published_at' do
    it 'creates a published tag' do
      time = Time.now
      expect(used_in_builder { |xml| helper.published_at(xml, time) }).to match "<published>#{time.iso8601}</published>"
    end
  end

  describe '#updated_at' do
    it 'creates an updated tag' do
      time = Time.now
      expect(used_in_builder { |xml| helper.updated_at(xml, time) }).to match "<updated>#{time.iso8601}</updated>"
    end
  end

  describe '#verb' do
    it 'creates an entry' do
      expect(used_with_namespaces { |xml| helper.verb(xml, 'verb') }).to match '<activity:verb>http://activitystrea.ms/schema/1.0/verb</activity:verb>'
    end
  end

  describe '#content' do
    it 'creates a content' do
      expect(used_in_builder { |xml| helper.content(xml, 'foo') }).to match '<content type="html">foo</content>'
    end
  end

  describe '#title' do
    it 'creates a title' do
      expect(used_in_builder { |xml| helper.title(xml, 'foo') }).to match '<title>foo</title>'
    end
  end

  describe '#author' do
    it 'creates an author' do
      expect(used_in_builder { |xml| helper.author(xml) }).to match '<author/>'
    end
  end

  describe '#target' do
    it 'creates a target' do
      expect(used_with_namespaces { |xml| helper.target(xml) }).to match '<activity:object/>'
    end
  end

  describe '#object_type' do
    it 'creates an object type' do
      expect(used_with_namespaces { |xml| helper.object_type(xml, 'test') }).to match '<activity:object-type>http://activitystrea.ms/schema/1.0/test</activity:object-type>'
    end
  end

  describe '#uri' do
    it 'creates a uri' do
      expect(used_in_builder { |xml| helper.uri(xml, 1) }).to match '<uri>1</uri>'
    end
  end

  describe '#name' do
    it 'creates a name' do
      expect(used_in_builder { |xml| helper.name(xml, 1) }).to match '<name>1</name>'
    end
  end

  describe '#summary' do
    it 'creates a summary' do
      expect(used_in_builder { |xml| helper.summary(xml, 1) }).to match '<summary>1</summary>'
    end
  end

  describe '#subtitle' do
    it 'creates a subtitle' do
      expect(used_in_builder { |xml| helper.subtitle(xml, 1) }).to match '<subtitle>1</subtitle>'
    end
  end

  describe '#link_alternate' do
    it 'creates a link' do
      expect(used_in_builder { |xml| helper.link_alternate(xml, 1) }).to match '<link rel="alternate" type="text/html" href="1"/>'
    end
  end

  describe '#link_self' do
    it 'creates a link' do
      expect(used_in_builder { |xml| helper.link_self(xml, 1) }).to match '<link rel="self" type="application/atom+xml" href="1"/>'
    end
  end

  describe '#link_hub' do
    it 'creates a link' do
      expect(used_in_builder { |xml| helper.link_hub(xml, 1) }).to match '<link rel="hub" href="1"/>'
    end
  end

  describe '#link_salmon' do
    it 'creates a link' do
      expect(used_in_builder { |xml| helper.link_salmon(xml, 1) }).to match '<link rel="salmon" href="1"/>'
    end
  end

  describe '#portable_contact' do
    let(:account) { Fabricate(:account, username: 'alice', display_name: 'Alice in Wonderland') }

    it 'creates portable contacts entries' do
      expect(used_with_namespaces { |xml| helper.portable_contact(xml, account) }).to match '<poco:displayName>Alice in Wonderland</poco:displayName>'
    end
  end

  describe '#in_reply_to' do
    it 'creates a thread' do
      expect(used_with_namespaces { |xml| helper.in_reply_to(xml, 'uri', 'url') }).to match '<thr:in-reply-to ref="uri" href="url" type="text/html"/>'
    end
  end

  describe '#link_mention' do
    let(:account) { Fabricate(:account, username: 'alice') }

    it 'creates a link' do
      expect(used_in_builder { |xml| helper.link_mention(xml, account) }).to match '<link rel="mentioned" href="https://cb6e6126.ngrok.io/users/alice"/>'
    end
  end

  describe '#include_author' do
    pending
  end

  describe '#include_entry' do
    pending
  end

  describe '#link_avatar' do
    let(:account) { Fabricate(:account, username: 'alice') }

    it 'creates a link' do
      expect(used_with_namespaces { |xml| helper.link_avatar(xml, account) }).to match '<link rel="avatar" type="" media:width="300" media:height="300" href="http://test.host/avatars/large/missing.png"/>'
    end
  end

  describe '#link_enclosure' do
    pending
  end

  describe '#logo' do
    it 'creates a logo' do
      expect(used_in_builder { |xml| helper.logo(xml, 1) }).to match '<logo>1</logo>'
    end
  end

  def used_in_builder(&block)
    builder = Nokogiri::XML::Builder.new(&block)
    builder.doc.root.to_xml
  end

  def used_with_namespaces(&block)
    used_in_builder { |xml| helper.entry(xml, true, &block) }
  end
end
