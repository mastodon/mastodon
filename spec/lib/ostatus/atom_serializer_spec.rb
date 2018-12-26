require 'rails_helper'

RSpec.describe OStatus::AtomSerializer do
  shared_examples 'follow request salmon' do
    it 'appends author element with account' do
      account = Fabricate(:account, domain: nil, username: 'username')
      follow_request = Fabricate(:follow_request, account: account)

      follow_request_salmon = serialize(follow_request)

      expect(follow_request_salmon.author.id.text).to eq 'https://cb6e6126.ngrok.io/users/username'
    end

    it 'appends activity:object-type element with activity type' do
      follow_request = Fabricate(:follow_request)

      follow_request_salmon = serialize(follow_request)

      object_type = follow_request_salmon.nodes.find { |node| node.name == 'activity:object-type' }
      expect(object_type.text).to eq OStatus::TagManager::TYPES[:activity]
    end

    it 'appends activity:verb element with request_friend type' do
      follow_request = Fabricate(:follow_request)

      follow_request_salmon = serialize(follow_request)

      verb = follow_request_salmon.nodes.find { |node| node.name == 'activity:verb' }
      expect(verb.text).to eq OStatus::TagManager::VERBS[:request_friend]
    end

    it 'appends activity:object with target account' do
      target_account = Fabricate(:account, domain: 'domain.test', uri: 'https://domain.test/id')
      follow_request = Fabricate(:follow_request, target_account: target_account)

      follow_request_salmon = serialize(follow_request)

      object = follow_request_salmon.nodes.find { |node| node.name == 'activity:object' }
      expect(object.id.text).to eq 'https://domain.test/id'
    end
  end

  shared_examples 'namespaces' do
    it 'adds namespaces' do
      element = serialize

      expect(element['xmlns']).to eq OStatus::TagManager::XMLNS
      expect(element['xmlns:thr']).to eq OStatus::TagManager::THR_XMLNS
      expect(element['xmlns:activity']).to eq OStatus::TagManager::AS_XMLNS
      expect(element['xmlns:poco']).to eq OStatus::TagManager::POCO_XMLNS
      expect(element['xmlns:media']).to eq OStatus::TagManager::MEDIA_XMLNS
      expect(element['xmlns:ostatus']).to eq OStatus::TagManager::OS_XMLNS
      expect(element['xmlns:mastodon']).to eq OStatus::TagManager::MTDN_XMLNS
    end
  end

  shared_examples 'no namespaces' do
    it 'does not add namespaces' do
      expect(serialize['xmlns']).to eq nil
    end
  end

  shared_examples 'status attributes' do
    it 'appends summary element with spoiler text if present' do
      status = Fabricate(:status, language: :ca, spoiler_text: 'spoiler text')

      element = serialize(status)

      summary = element.summary
      expect(summary['xml:lang']).to eq 'ca'
      expect(summary.text).to eq 'spoiler text'
    end

    it 'does not append summary element with spoiler text if not present' do
      status = Fabricate(:status, spoiler_text: '')
      element = serialize(status)
      element.nodes.each { |node| expect(node.name).not_to eq 'summary' }
    end

    it 'appends content element with formatted status' do
      status = Fabricate(:status, language: :ca, text: 'text')

      element = serialize(status)

      content = element.content
      expect(content[:type]).to eq 'html'
      expect(content['xml:lang']).to eq 'ca'
      expect(content.text).to eq '<p>text</p>'
    end

    it 'appends link elements for mentioned accounts' do
      account = Fabricate(:account, username: 'username')
      status = Fabricate(:status)
      Fabricate(:mention, account: account, status: status)

      element = serialize(status)

      mentioned = element.nodes.find do |node|
        node.name == 'link' &&
          node[:rel] == 'mentioned' &&
          node['ostatus:object-type'] == OStatus::TagManager::TYPES[:person]
      end

      expect(mentioned[:href]).to eq 'https://cb6e6126.ngrok.io/users/username'
    end

    it 'appends link elements for emojis' do
      Fabricate(:custom_emoji)

      status  = Fabricate(:status, text: ':coolcat:')
      element = serialize(status)
      emoji   = element.nodes.find { |node| node.name == 'link' && node[:rel] == 'emoji' }

      expect(emoji[:name]).to eq 'coolcat'
      expect(emoji[:href]).to_not be_blank
    end
  end

  describe 'render' do
    it 'returns XML with emojis' do
      element = Ox::Element.new('tag')
      element << '💩'
      xml = OStatus::AtomSerializer.render(element)

      expect(xml).to eq "<?xml version=\"1.0\"?>\n<tag>💩</tag>\n"
    end

    it 'returns XML, stripping invalid characters like \b and \v' do
      element = Ox::Element.new('tag')
      element << "im l33t\b haxo\b\vr"
      xml = OStatus::AtomSerializer.render(element)

      expect(xml).to eq "<?xml version=\"1.0\"?>\n<tag>im l33t haxor</tag>\n"
    end
  end

  describe '#author' do
    context 'when note is present' do
      it 'appends poco:note element with note for local account' do
        account = Fabricate(:account, domain: nil, note: '<p>note</p>')

        author = OStatus::AtomSerializer.new.author(account)

        note = author.nodes.find { |node| node.name == 'poco:note' }
        expect(note.text).to eq '<p>note</p>'
      end

      it 'appends poco:note element with tags-stripped note for remote account' do
        account = Fabricate(:account, domain: 'remote', note: '<p>note</p>')

        author = OStatus::AtomSerializer.new.author(account)

        note = author.nodes.find { |node| node.name == 'poco:note' }
        expect(note.text).to eq 'note'
      end

      it 'appends summary element with type attribute and simplified note if present' do
        account = Fabricate(:account, note: 'note')
        author = OStatus::AtomSerializer.new.author(account)
        expect(author.summary.text).to eq '<p>note</p>'
        expect(author.summary[:type]).to eq 'html'
      end
    end

    context 'when note is not present' do
      it 'does not append poco:note element' do
        account = Fabricate(:account, note: '')
        author = OStatus::AtomSerializer.new.author(account)
        author.nodes.each { |node| expect(node.name).not_to eq 'poco:note' }
      end

      it 'does not append summary element' do
        account = Fabricate(:account, note: '')
        author = OStatus::AtomSerializer.new.author(account)
        author.nodes.each { |node| expect(node.name).not_to eq 'summary' }
      end
    end

    it 'returns author element' do
      account = Fabricate(:account)
      author = OStatus::AtomSerializer.new.author(account)
      expect(author.name).to eq 'author'
    end

    it 'appends activity:object-type element with person type' do
      account = Fabricate(:account, domain: nil, username: 'username')

      author = OStatus::AtomSerializer.new.author(account)

      object_type = author.nodes.find { |node| node.name == 'activity:object-type' }
      expect(object_type.text).to eq OStatus::TagManager::TYPES[:person]
    end

    it 'appends email element with username and domain for local account' do
      account = Fabricate(:account, username: 'username')
      author = OStatus::AtomSerializer.new.author(account)
      expect(author.email.text).to eq 'username@cb6e6126.ngrok.io'
    end

    it 'appends email element with username and domain for remote user' do
      account = Fabricate(:account, domain: 'domain', username: 'username')
      author = OStatus::AtomSerializer.new.author(account)
      expect(author.email.text).to eq 'username@domain'
    end

    it 'appends link element for an alternative' do
      account = Fabricate(:account, domain: nil, username: 'username')

      author = OStatus::AtomSerializer.new.author(account)

      link = author.nodes.find { |node| node.name == 'link' && node[:rel] == 'alternate' && node[:type] == 'text/html' }
      expect(link[:type]).to eq 'text/html'
      expect(link[:rel]).to eq 'alternate'
      expect(link[:href]).to eq 'https://cb6e6126.ngrok.io/@username'
    end

    it 'has link element for avatar if present' do
      account = Fabricate(:account, avatar: attachment_fixture('avatar.gif'))

      author = OStatus::AtomSerializer.new.author(account)

      link = author.nodes.find { |node| node.name == 'link' && node[:rel] == 'avatar' }
      expect(link[:type]).to eq 'image/gif'
      expect(link['media:width']).to eq '120'
      expect(link['media:height']).to eq '120'
      expect(link[:href]).to match  /^https:\/\/cb6e6126.ngrok.io\/system\/accounts\/avatars\/.+\/original\/avatar.gif/
    end

    it 'does not have link element for avatar if not present' do
      account = Fabricate(:account, avatar: nil)

      author = OStatus::AtomSerializer.new.author(account)

      author.nodes.each do |node|
        expect(node[:rel]).not_to eq 'avatar' if node.name == 'link'
      end
    end

    it 'appends link element for header if present' do
      account = Fabricate(:account, header: attachment_fixture('avatar.gif'))

      author = OStatus::AtomSerializer.new.author(account)

      link = author.nodes.find { |node| node.name == 'link' && node[:rel] == 'header' }
      expect(link[:type]).to eq 'image/gif'
      expect(link['media:width']).to eq '700'
      expect(link['media:height']).to eq '335'
      expect(link[:href]).to match  /^https:\/\/cb6e6126.ngrok.io\/system\/accounts\/headers\/.+\/original\/avatar.gif/
    end

    it 'does not append link element for header if not present' do
      account = Fabricate(:account, header: nil)

      author = OStatus::AtomSerializer.new.author(account)

      author.nodes.each do |node|
        expect(node[:rel]).not_to eq 'header' if node.name == 'link'
      end
    end

    it 'appends poco:displayName element with display name if present' do
      account = Fabricate(:account, display_name: 'display name')

      author = OStatus::AtomSerializer.new.author(account)

      display_name = author.nodes.find { |node| node.name == 'poco:displayName' }
      expect(display_name.text).to eq 'display name'
    end

    it 'does not append poco:displayName element with display name if not present' do
      account = Fabricate(:account, display_name: '')
      author = OStatus::AtomSerializer.new.author(account)
      author.nodes.each { |node| expect(node.name).not_to eq 'poco:displayName' }
    end

    it "appends mastodon:scope element with 'private' if locked" do
      account = Fabricate(:account, locked: true)

      author = OStatus::AtomSerializer.new.author(account)

      scope = author.nodes.find { |node| node.name == 'mastodon:scope' }
      expect(scope.text).to eq 'private'
    end

    it "appends mastodon:scope element with 'public' if unlocked" do
      account = Fabricate(:account, locked: false)

      author = OStatus::AtomSerializer.new.author(account)

      scope = author.nodes.find { |node| node.name == 'mastodon:scope' }
      expect(scope.text).to eq 'public'
    end

    it 'includes URI' do
      account = Fabricate(:account, domain: nil, username: 'username')

      author = OStatus::AtomSerializer.new.author(account)

      expect(author.id.text).to eq 'https://cb6e6126.ngrok.io/users/username'
      expect(author.uri.text).to eq 'https://cb6e6126.ngrok.io/users/username'
    end

    it 'includes username' do
      account = Fabricate(:account, username: 'username')

      author = OStatus::AtomSerializer.new.author(account)

      name = author.nodes.find { |node| node.name == 'name' }
      username = author.nodes.find { |node| node.name == 'poco:preferredUsername' }
      expect(name.text).to eq 'username'
      expect(username.text).to eq 'username'
    end
  end

  describe '#entry' do
    shared_examples 'not root' do
      include_examples 'no namespaces' do
        def serialize
          subject
        end
      end

      it 'does not append author element' do
        subject.nodes.each { |node| expect(node.name).not_to eq 'author' }
      end
    end

    context 'it is root' do
      include_examples 'namespaces' do
        def serialize
          stream_entry = Fabricate(:stream_entry)
          OStatus::AtomSerializer.new.entry(stream_entry, true)
        end
      end

      it 'appends author element' do
        account = Fabricate(:account, username: 'username')
        status = Fabricate(:status, account: account)

        entry = OStatus::AtomSerializer.new.entry(status.stream_entry, true)

        expect(entry.author.id.text).to eq 'https://cb6e6126.ngrok.io/users/username'
      end
    end

    context 'if status is present' do
      include_examples 'status attributes' do
        def serialize(status)
          OStatus::AtomSerializer.new.entry(status.stream_entry, true)
        end
      end

      it 'appends link element for the public collection if status is publicly visible' do
        status = Fabricate(:status, visibility: :public)

        entry = OStatus::AtomSerializer.new.entry(status.stream_entry)

        mentioned_person = entry.nodes.find do |node|
          node.name == 'link' &&
          node[:rel] == 'mentioned' &&
          node['ostatus:object-type'] == OStatus::TagManager::TYPES[:collection]
        end
        expect(mentioned_person[:href]).to eq OStatus::TagManager::COLLECTIONS[:public]
      end

      it 'does not append link element for the public collection if status is not publicly visible' do
        status = Fabricate(:status, visibility: :private)

        entry = OStatus::AtomSerializer.new.entry(status.stream_entry)

        entry.nodes.each do |node|
          if node.name == 'link' &&
             node[:rel] == 'mentioned' &&
             node['ostatus:object-type'] == OStatus::TagManager::TYPES[:collection]
            expect(mentioned_collection[:href]).not_to eq OStatus::TagManager::COLLECTIONS[:public]
          end
        end
      end

      it 'appends category elements for tags' do
        tag = Fabricate(:tag, name: 'tag')
        status = Fabricate(:status, tags: [ tag ])

        entry = OStatus::AtomSerializer.new.entry(status.stream_entry)

        expect(entry.category[:term]).to eq 'tag'
      end

      it 'appends link elements for media attachments' do
        file = attachment_fixture('attachment.jpg')
        media_attachment = Fabricate(:media_attachment, file: file)
        status = Fabricate(:status, media_attachments: [ media_attachment ])

        entry = OStatus::AtomSerializer.new.entry(status.stream_entry)

        enclosure = entry.nodes.find { |node| node.name == 'link' && node[:rel] == 'enclosure' }
        expect(enclosure[:type]).to eq 'image/jpeg'
        expect(enclosure[:href]).to match /^https:\/\/cb6e6126.ngrok.io\/system\/media_attachments\/files\/.+\/original\/attachment.jpg$/
      end

      it 'appends mastodon:scope element with visibility' do
        status = Fabricate(:status, visibility: :public)

        entry = OStatus::AtomSerializer.new.entry(status.stream_entry)

        scope = entry.nodes.find { |node| node.name == 'mastodon:scope' }
        expect(scope.text).to eq 'public'
      end

      it 'returns element whose rendered view triggers creation when processed' do
        remote_account = Account.create!(username: 'username')
        remote_status = Fabricate(:status, account: remote_account, created_at: '2000-01-01T00:00:00Z')

        entry = OStatus::AtomSerializer.new.entry(remote_status.stream_entry, true)
        entry.nodes.delete_if { |node| node[:type] == 'application/activity+json' } # Remove ActivityPub link to simplify test
        xml = OStatus::AtomSerializer.render(entry).gsub('cb6e6126.ngrok.io', 'remote.test')

        remote_status.destroy!
        remote_account.destroy!

        account = Account.create!(
          domain: 'remote.test',
          username: 'username',
          last_webfingered_at: Time.now.utc
        )

        ProcessFeedService.new.call(xml, account)

        expect(Status.find_by(uri: "https://remote.test/users/#{remote_status.account.to_param}/statuses/#{remote_status.id}")).to be_instance_of Status
      end
    end

    context 'if status is not present' do
      it 'appends content element saying status is deleted' do
        status = Fabricate(:status)
        status.destroy!

        entry = OStatus::AtomSerializer.new.entry(status.stream_entry)

        expect(entry.content.text).to eq 'Deleted status'
      end

      it 'appends title element saying the status is deleted' do
        account = Fabricate(:account, username: 'username')
        status = Fabricate(:status, account: account)
        status.destroy!

        entry = OStatus::AtomSerializer.new.entry(status.stream_entry)

        expect(entry.title.text).to eq 'username deleted status'
      end
    end

    context 'it is not root' do
      let(:stream_entry) { Fabricate(:stream_entry) }
      subject { OStatus::AtomSerializer.new.entry(stream_entry, false) }
      include_examples 'not root'
    end

    context 'without root parameter' do
      let(:stream_entry) { Fabricate(:stream_entry) }
      subject { OStatus::AtomSerializer.new.entry(stream_entry) }
      include_examples 'not root'
    end

    it 'returns entry element' do
      stream_entry = Fabricate(:stream_entry)
      entry = OStatus::AtomSerializer.new.entry(stream_entry)
      expect(entry.name).to eq 'entry'
    end

    it 'appends id element with unique tag' do
      status = Fabricate(:status, reblog_of_id: nil, created_at: '2000-01-01T00:00:00Z')

      entry = OStatus::AtomSerializer.new.entry(status.stream_entry)

      expect(entry.id.text).to eq "https://cb6e6126.ngrok.io/users/#{status.account.to_param}/statuses/#{status.id}"
    end

    it 'appends published element with created date' do
      stream_entry = Fabricate(:stream_entry, created_at: '2000-01-01T00:00:00Z')
      entry = OStatus::AtomSerializer.new.entry(stream_entry)
      expect(entry.published.text).to eq '2000-01-01T00:00:00Z'
    end

    it 'appends updated element with updated date' do
      stream_entry = Fabricate(:stream_entry, updated_at: '2000-01-01T00:00:00Z')
      entry = OStatus::AtomSerializer.new.entry(stream_entry)
      expect(entry.updated.text).to eq '2000-01-01T00:00:00Z'
    end

    it 'appends title element with status title' do
      account = Fabricate(:account, username: 'username')
      status = Fabricate(:status, account: account, reblog_of_id: nil)
      entry = OStatus::AtomSerializer.new.entry(status.stream_entry)
      expect(entry.title.text).to eq 'New status by username'
    end

    it 'appends activity:object-type element with object type' do
      status = Fabricate(:status)
      entry = OStatus::AtomSerializer.new.entry(status.stream_entry)
      object_type = entry.nodes.find { |node| node.name == 'activity:object-type' }
      expect(object_type.text).to eq OStatus::TagManager::TYPES[:note]
    end

    it 'appends activity:verb element with object type' do
      status = Fabricate(:status)

      entry = OStatus::AtomSerializer.new.entry(status.stream_entry)

      object_type = entry.nodes.find { |node| node.name == 'activity:verb' }
      expect(object_type.text).to eq OStatus::TagManager::VERBS[:post]
    end

    it 'appends activity:object element with target if present' do
      reblogged = Fabricate(:status, created_at: '2000-01-01T00:00:00Z')
      reblog = Fabricate(:status, reblog: reblogged)

      entry = OStatus::AtomSerializer.new.entry(reblog.stream_entry)

      object = entry.nodes.find { |node| node.name == 'activity:object' }
      expect(object.id.text).to eq "https://cb6e6126.ngrok.io/users/#{reblogged.account.to_param}/statuses/#{reblogged.id}"
    end

    it 'does not append activity:object element if target is not present' do
      status = Fabricate(:status, reblog_of_id: nil)
      entry = OStatus::AtomSerializer.new.entry(status.stream_entry)
      entry.nodes.each { |node| expect(node.name).not_to eq 'activity:object' }
    end

    it 'appends link element for an alternative' do
      account = Fabricate(:account, username: 'username')
      status = Fabricate(:status, account: account)

      entry = OStatus::AtomSerializer.new.entry(status.stream_entry)

      link = entry.nodes.find { |node| node.name == 'link' && node[:rel] == 'alternate' && node[:type] == 'text/html' }
      expect(link[:type]).to eq 'text/html'
      expect(link[:href]).to eq "https://cb6e6126.ngrok.io/@username/#{status.id}"
    end

    it 'appends link element for itself' do
      account = Fabricate(:account, username: 'username')
      status = Fabricate(:status, account: account)

      entry = OStatus::AtomSerializer.new.entry(status.stream_entry)

      link = entry.nodes.find { |node| node.name == 'link' && node[:rel] == 'self' }
      expect(link[:type]).to eq 'application/atom+xml'
      expect(link[:href]).to eq "https://cb6e6126.ngrok.io/users/username/updates/#{status.stream_entry.id}.atom"
    end

    it 'appends thr:in-reply-to element if threaded' do
      in_reply_to_status = Fabricate(:status, created_at: '2000-01-01T00:00:00Z', reblog_of_id: nil)
      reply_status = Fabricate(:status, in_reply_to_id: in_reply_to_status.id)

      entry = OStatus::AtomSerializer.new.entry(reply_status.stream_entry)

      in_reply_to = entry.nodes.find { |node| node.name == 'thr:in-reply-to' }
      expect(in_reply_to[:ref]).to eq "https://cb6e6126.ngrok.io/users/#{in_reply_to_status.account.to_param}/statuses/#{in_reply_to_status.id}"
    end

    it 'does not append thr:in-reply-to element if not threaded' do
      status = Fabricate(:status)
      entry = OStatus::AtomSerializer.new.entry(status.stream_entry)
      entry.nodes.each { |node| expect(node.name).not_to eq 'thr:in-reply-to' }
    end

    it 'appends ostatus:conversation if conversation id is present' do
      status = Fabricate(:status)
      status.conversation.update!(created_at: '2000-01-01T00:00:00Z')

      entry = OStatus::AtomSerializer.new.entry(status.stream_entry)

      conversation = entry.nodes.find { |node| node.name == 'ostatus:conversation' }
      expect(conversation[:ref]).to eq "tag:cb6e6126.ngrok.io,2000-01-01:objectId=#{status.conversation_id}:objectType=Conversation"
    end

    it 'does not append ostatus:conversation if conversation id is not present' do
      status = Fabricate.build(:status, conversation_id: nil)
      status.save!(validate: false)

      entry = OStatus::AtomSerializer.new.entry(status.stream_entry)

      entry.nodes.each { |node| expect(node.name).not_to eq 'ostatus:conversation' }
    end
  end

  describe '#feed' do
    include_examples 'namespaces' do
      def serialize
        account = Fabricate(:account)
        OStatus::AtomSerializer.new.feed(account, [])
      end
    end

    it 'returns feed element' do
      account = Fabricate(:account)
      feed = OStatus::AtomSerializer.new.feed(account, [])
      expect(feed.name).to eq 'feed'
    end

    it 'appends id element with account Atom URL' do
      account = Fabricate(:account, username: 'username')
      feed = OStatus::AtomSerializer.new.feed(account, [])
      expect(feed.id.text).to eq 'https://cb6e6126.ngrok.io/users/username.atom'
    end

    it 'appends title element with account display name if present' do
      account = Fabricate(:account, display_name: 'display name')
      feed = OStatus::AtomSerializer.new.feed(account, [])
      expect(feed.title.text).to eq 'display name'
    end

    it 'does not append title element with account username if account display name is not present' do
      account = Fabricate(:account, display_name: '', username: 'username')
      feed = OStatus::AtomSerializer.new.feed(account, [])
      expect(feed.title.text).to eq 'username'
    end

    it 'appends subtitle element with account note' do
      account = Fabricate(:account, note: 'note')
      feed = OStatus::AtomSerializer.new.feed(account, [])
      expect(feed.subtitle.text).to eq 'note'
    end

    it 'appends updated element with date account got updated' do
      account = Fabricate(:account, updated_at: '2000-01-01T00:00:00Z')
      feed = OStatus::AtomSerializer.new.feed(account, [])
      expect(feed.updated.text).to eq '2000-01-01T00:00:00Z'
    end

    it 'appends logo element with full asset URL for original account avatar' do
      account = Fabricate(:account, avatar: attachment_fixture('avatar.gif'))
      feed = OStatus::AtomSerializer.new.feed(account, [])
      expect(feed.logo.text).to match /^https:\/\/cb6e6126.ngrok.io\/system\/accounts\/avatars\/.+\/original\/avatar.gif/
    end

    it 'appends author element' do
      account = Fabricate(:account, username: 'username')
      feed = OStatus::AtomSerializer.new.feed(account, [])
      expect(feed.author.id.text).to eq 'https://cb6e6126.ngrok.io/users/username'
    end

    it 'appends link element for an alternative' do
      account = Fabricate(:account, username: 'username')

      feed = OStatus::AtomSerializer.new.feed(account, [])

      link = feed.nodes.find { |node| node.name == 'link' && node[:rel] == 'alternate' && node[:type] == 'text/html' }
      expect(link[:type]).to eq 'text/html'
      expect(link[:href]).to eq 'https://cb6e6126.ngrok.io/@username'
    end

    it 'appends link element for itself' do
      account = Fabricate(:account, username: 'username')

      feed = OStatus::AtomSerializer.new.feed(account, [])

      link = feed.nodes.find { |node| node.name == 'link' && node[:rel] == 'self' }
      expect(link[:type]).to eq 'application/atom+xml'
      expect(link[:href]).to eq 'https://cb6e6126.ngrok.io/users/username.atom'
    end

    it 'appends link element for the next if it has 20 stream entries' do
      account = Fabricate(:account, username: 'username')
      stream_entry = Fabricate(:stream_entry)

      feed = OStatus::AtomSerializer.new.feed(account, Array.new(20, stream_entry))

      link = feed.nodes.find { |node| node.name == 'link' && node[:rel] == 'next' }
      expect(link[:type]).to eq 'application/atom+xml'
      expect(link[:href]).to eq "https://cb6e6126.ngrok.io/users/username.atom?max_id=#{stream_entry.id}"
    end

    it 'does not append link element for the next if it does not have 20 stream entries' do
      account = Fabricate(:account, username: 'username')

      feed = OStatus::AtomSerializer.new.feed(account, [])

      feed.nodes.each do |node|
        expect(node[:rel]).not_to eq 'next' if node.name == 'link'
      end
    end

    it 'appends link element for hub' do
      account = Fabricate(:account, username: 'username')

      feed = OStatus::AtomSerializer.new.feed(account, [])

      link = feed.nodes.find { |node| node.name == 'link' && node[:rel] == 'hub' }
      expect(link[:href]).to eq 'https://cb6e6126.ngrok.io/api/push'
    end

    it 'appends link element for Salmon' do
      account = Fabricate(:account, username: 'username')

      feed = OStatus::AtomSerializer.new.feed(account, [])

      link = feed.nodes.find { |node| node.name == 'link' && node[:rel] == 'salmon' }
      expect(link[:href]).to start_with 'https://cb6e6126.ngrok.io/api/salmon/'
    end

    it 'appends stream entries' do
      account = Fabricate(:account, username: 'username')
      status = Fabricate(:status, account: account)

      feed = OStatus::AtomSerializer.new.feed(account, [status.stream_entry])

      expect(feed.entry.title.text).to eq 'New status by username'
    end
  end

  describe '#block_salmon' do
    include_examples 'namespaces' do
      def serialize
        block = Fabricate(:block)
        OStatus::AtomSerializer.new.block_salmon(block)
      end
    end

    it 'returns entry element' do
      block = Fabricate(:block)
      block_salmon = OStatus::AtomSerializer.new.block_salmon(block)
      expect(block_salmon.name).to eq 'entry'
    end

    it 'appends id element with unique tag' do
      block = Fabricate(:block)

      time_before = Time.zone.now
      block_salmon = OStatus::AtomSerializer.new.block_salmon(block)
      time_after = Time.zone.now

      expect(block_salmon.id.text).to(
        eq(OStatus::TagManager.instance.unique_tag(time_before.utc, block.id, 'Block'))
          .or(eq(OStatus::TagManager.instance.unique_tag(time_after.utc, block.id, 'Block')))
      )
    end

    it 'appends title element with description' do
      account = Fabricate(:account, domain: nil, username: 'account')
      target_account = Fabricate(:account, domain: 'remote', username: 'target_account')
      block = Fabricate(:block, account: account, target_account: target_account)

      block_salmon = OStatus::AtomSerializer.new.block_salmon(block)

      expect(block_salmon.title.text).to eq 'account no longer wishes to interact with target_account@remote'
    end

    it 'appends author element with account' do
      account = Fabricate(:account, domain: nil, username: 'account')
      block = Fabricate(:block, account: account)

      block_salmon = OStatus::AtomSerializer.new.block_salmon(block)

      expect(block_salmon.author.id.text).to eq 'https://cb6e6126.ngrok.io/users/account'
    end

    it 'appends activity:object-type element with activity type' do
      block = Fabricate(:block)

      block_salmon = OStatus::AtomSerializer.new.block_salmon(block)

      object_type = block_salmon.nodes.find { |node| node.name == 'activity:object-type' }
      expect(object_type.text).to eq OStatus::TagManager::TYPES[:activity]
    end

    it 'appends activity:verb element with block' do
      block = Fabricate(:block)

      block_salmon = OStatus::AtomSerializer.new.block_salmon(block)

      verb = block_salmon.nodes.find { |node| node.name == 'activity:verb' }
      expect(verb.text).to eq OStatus::TagManager::VERBS[:block]
    end

    it 'appends activity:object element with target account' do
      target_account = Fabricate(:account, domain: 'domain.test', uri: 'https://domain.test/id')
      block = Fabricate(:block, target_account: target_account)

      block_salmon = OStatus::AtomSerializer.new.block_salmon(block)

      object = block_salmon.nodes.find { |node| node.name == 'activity:object' }
      expect(object.id.text).to eq 'https://domain.test/id'
    end

    it 'returns element whose rendered view triggers block when processed' do
      block = Fabricate(:block)
      block_salmon = OStatus::AtomSerializer.new.block_salmon(block)
      xml = OStatus::AtomSerializer.render(block_salmon)
      envelope = OStatus2::Salmon.new.pack(xml, block.account.keypair)
      block.destroy!

      ProcessInteractionService.new.call(envelope, block.target_account)

      expect(block.account.blocking?(block.target_account)).to be true
    end
  end

  describe '#unblock_salmon' do
    include_examples 'namespaces' do
      def serialize
        block = Fabricate(:block)
        OStatus::AtomSerializer.new.unblock_salmon(block)
      end
    end

    it 'returns entry element' do
      block = Fabricate(:block)
      unblock_salmon = OStatus::AtomSerializer.new.unblock_salmon(block)
      expect(unblock_salmon.name).to eq 'entry'
    end

    it 'appends id element with unique tag' do
      block = Fabricate(:block)

      time_before = Time.zone.now
      unblock_salmon = OStatus::AtomSerializer.new.unblock_salmon(block)
      time_after = Time.zone.now

      expect(unblock_salmon.id.text).to(
        eq(OStatus::TagManager.instance.unique_tag(time_before.utc, block.id, 'Block'))
          .or(eq(OStatus::TagManager.instance.unique_tag(time_after.utc, block.id, 'Block')))
      )
    end

    it 'appends title element with description' do
      account = Fabricate(:account, domain: nil, username: 'account')
      target_account = Fabricate(:account, domain: 'remote', username: 'target_account')
      block = Fabricate(:block, account: account, target_account: target_account)

      unblock_salmon = OStatus::AtomSerializer.new.unblock_salmon(block)

      expect(unblock_salmon.title.text).to eq 'account no longer blocks target_account@remote'
    end

    it 'appends author element with account' do
      account = Fabricate(:account, domain: nil, username: 'account')
      block = Fabricate(:block, account: account)

      unblock_salmon = OStatus::AtomSerializer.new.unblock_salmon(block)

      expect(unblock_salmon.author.id.text).to eq 'https://cb6e6126.ngrok.io/users/account'
    end

    it 'appends activity:object-type element with activity type' do
      block = Fabricate(:block)

      unblock_salmon = OStatus::AtomSerializer.new.unblock_salmon(block)

      object_type = unblock_salmon.nodes.find { |node| node.name == 'activity:object-type' }
      expect(object_type.text).to eq OStatus::TagManager::TYPES[:activity]
    end

    it 'appends activity:verb element with block' do
      block = Fabricate(:block)

      unblock_salmon = OStatus::AtomSerializer.new.unblock_salmon(block)

      verb = unblock_salmon.nodes.find { |node| node.name == 'activity:verb' }
      expect(verb.text).to eq OStatus::TagManager::VERBS[:unblock]
    end

    it 'appends activity:object element with target account' do
      target_account = Fabricate(:account, domain: 'domain.test', uri: 'https://domain.test/id')
      block = Fabricate(:block, target_account: target_account)

      unblock_salmon = OStatus::AtomSerializer.new.unblock_salmon(block)

      object = unblock_salmon.nodes.find { |node| node.name == 'activity:object' }
      expect(object.id.text).to eq 'https://domain.test/id'
    end

    it 'returns element whose rendered view triggers block when processed' do
      block = Fabricate(:block)
      unblock_salmon = OStatus::AtomSerializer.new.unblock_salmon(block)
      xml = OStatus::AtomSerializer.render(unblock_salmon)
      envelope = OStatus2::Salmon.new.pack(xml, block.account.keypair)

      ProcessInteractionService.new.call(envelope, block.target_account)

      expect { block.reload }.to raise_error ActiveRecord::RecordNotFound
    end
  end

  describe '#favourite_salmon' do
    include_examples 'namespaces' do
      def serialize
        favourite = Fabricate(:favourite)
        OStatus::AtomSerializer.new.favourite_salmon(favourite)
      end
    end

    it 'returns entry element' do
      favourite = Fabricate(:favourite)
      favourite_salmon = OStatus::AtomSerializer.new.favourite_salmon(favourite)
      expect(favourite_salmon.name).to eq 'entry'
    end

    it 'appends id element with unique tag' do
      favourite = Fabricate(:favourite, created_at: '2000-01-01T00:00:00Z')
      favourite_salmon = OStatus::AtomSerializer.new.favourite_salmon(favourite)
      expect(favourite_salmon.id.text).to eq "tag:cb6e6126.ngrok.io,2000-01-01:objectId=#{favourite.id}:objectType=Favourite"
    end

    it 'appends author element with account' do
      account = Fabricate(:account, domain: nil, username: 'username')
      favourite = Fabricate(:favourite, account: account)

      favourite_salmon = OStatus::AtomSerializer.new.favourite_salmon(favourite)

      expect(favourite_salmon.author.id.text).to eq 'https://cb6e6126.ngrok.io/users/username'
    end

    it 'appends activity:object-type element with activity type' do
      favourite = Fabricate(:favourite)

      favourite_salmon = OStatus::AtomSerializer.new.favourite_salmon(favourite)

      object_type = favourite_salmon.nodes.find { |node| node.name == 'activity:object-type' }
      expect(object_type.text).to eq 'http://activitystrea.ms/schema/1.0/activity'
    end

    it 'appends activity:verb element with favorite' do
      favourite = Fabricate(:favourite)

      favourite_salmon = OStatus::AtomSerializer.new.favourite_salmon(favourite)

      verb = favourite_salmon.nodes.find { |node| node.name == 'activity:verb' }
      expect(verb.text).to eq OStatus::TagManager::VERBS[:favorite]
    end

    it 'appends activity:object element with status' do
      status = Fabricate(:status, created_at: '2000-01-01T00:00:00Z')
      favourite = Fabricate(:favourite, status: status)

      favourite_salmon = OStatus::AtomSerializer.new.favourite_salmon(favourite)

      object = favourite_salmon.nodes.find { |node| node.name == 'activity:object' }
      expect(object.id.text).to eq "https://cb6e6126.ngrok.io/users/#{status.account.to_param}/statuses/#{status.id}"
    end

    it 'appends thr:in-reply-to element for status' do
      status_account = Fabricate(:account, username: 'username')
      status = Fabricate(:status, account: status_account, created_at: '2000-01-01T00:00:00Z')
      favourite = Fabricate(:favourite, status: status)

      favourite_salmon = OStatus::AtomSerializer.new.favourite_salmon(favourite)

      in_reply_to = favourite_salmon.nodes.find { |node| node.name == 'thr:in-reply-to' }
      expect(in_reply_to.ref).to eq "https://cb6e6126.ngrok.io/users/#{status.account.to_param}/statuses/#{status.id}"
      expect(in_reply_to.href).to eq "https://cb6e6126.ngrok.io/@username/#{status.id}"
    end

    it 'includes description' do
      account = Fabricate(:account, domain: nil, username: 'account')
      status_account = Fabricate(:account, domain: 'remote', username: 'status_account')
      status = Fabricate(:status, account: status_account)
      favourite = Fabricate(:favourite, account: account, status: status)

      favourite_salmon = OStatus::AtomSerializer.new.favourite_salmon(favourite)

      expect(favourite_salmon.title.text).to eq 'account favourited a status by status_account@remote'
      expect(favourite_salmon.content.text).to eq 'account favourited a status by status_account@remote'
    end

    it 'returns element whose rendered view triggers favourite when processed' do
      favourite = Fabricate(:favourite)
      favourite_salmon = OStatus::AtomSerializer.new.favourite_salmon(favourite)
      xml = OStatus::AtomSerializer.render(favourite_salmon)
      envelope = OStatus2::Salmon.new.pack(xml, favourite.account.keypair)
      favourite.destroy!

      ProcessInteractionService.new.call(envelope, favourite.status.account)
      expect(favourite.account.favourited?(favourite.status)).to be true
    end
  end

  describe '#unfavourite_salmon' do
    include_examples 'namespaces' do
      def serialize
        favourite = Fabricate(:favourite)
        OStatus::AtomSerializer.new.favourite_salmon(favourite)
      end
    end

    it 'returns entry element' do
      favourite = Fabricate(:favourite)
      unfavourite_salmon = OStatus::AtomSerializer.new.unfavourite_salmon(favourite)
      expect(unfavourite_salmon.name).to eq 'entry'
    end

    it 'appends id element with unique tag' do
      favourite = Fabricate(:favourite)

      time_before = Time.zone.now
      unfavourite_salmon = OStatus::AtomSerializer.new.unfavourite_salmon(favourite)
      time_after = Time.zone.now

      expect(unfavourite_salmon.id.text).to(
        eq(OStatus::TagManager.instance.unique_tag(time_before.utc, favourite.id, 'Favourite'))
          .or(eq(OStatus::TagManager.instance.unique_tag(time_after.utc, favourite.id, 'Favourite')))
      )
    end

    it 'appends author element with account' do
      account = Fabricate(:account, domain: nil, username: 'username')
      favourite = Fabricate(:favourite, account: account)

      unfavourite_salmon = OStatus::AtomSerializer.new.unfavourite_salmon(favourite)

      expect(unfavourite_salmon.author.id.text).to eq 'https://cb6e6126.ngrok.io/users/username'
    end

    it 'appends activity:object-type element with activity type' do
      favourite = Fabricate(:favourite)

      unfavourite_salmon = OStatus::AtomSerializer.new.unfavourite_salmon(favourite)

      object_type = unfavourite_salmon.nodes.find { |node| node.name == 'activity:object-type' }
      expect(object_type.text).to eq 'http://activitystrea.ms/schema/1.0/activity'
    end

    it 'appends activity:verb element with favorite' do
      favourite = Fabricate(:favourite)

      unfavourite_salmon = OStatus::AtomSerializer.new.unfavourite_salmon(favourite)

      verb = unfavourite_salmon.nodes.find { |node| node.name == 'activity:verb' }
      expect(verb.text).to eq OStatus::TagManager::VERBS[:unfavorite]
    end

    it 'appends activity:object element with status' do
      status = Fabricate(:status, created_at: '2000-01-01T00:00:00Z')
      favourite = Fabricate(:favourite, status: status)

      unfavourite_salmon = OStatus::AtomSerializer.new.unfavourite_salmon(favourite)

      object = unfavourite_salmon.nodes.find { |node| node.name == 'activity:object' }
      expect(object.id.text).to eq "https://cb6e6126.ngrok.io/users/#{status.account.to_param}/statuses/#{status.id}"
    end

    it 'appends thr:in-reply-to element for status' do
      status_account = Fabricate(:account, username: 'username')
      status = Fabricate(:status, account: status_account, created_at: '2000-01-01T00:00:00Z')
      favourite = Fabricate(:favourite, status: status)

      unfavourite_salmon = OStatus::AtomSerializer.new.unfavourite_salmon(favourite)

      in_reply_to = unfavourite_salmon.nodes.find { |node| node.name == 'thr:in-reply-to' }
      expect(in_reply_to.ref).to eq "https://cb6e6126.ngrok.io/users/#{status.account.to_param}/statuses/#{status.id}"
      expect(in_reply_to.href).to eq "https://cb6e6126.ngrok.io/@username/#{status.id}"
    end

    it 'includes description' do
      account = Fabricate(:account, domain: nil, username: 'account')
      status_account = Fabricate(:account, domain: 'remote', username: 'status_account')
      status = Fabricate(:status, account: status_account)
      favourite = Fabricate(:favourite, account: account, status: status)

      unfavourite_salmon = OStatus::AtomSerializer.new.unfavourite_salmon(favourite)

      expect(unfavourite_salmon.title.text).to eq 'account no longer favourites a status by status_account@remote'
      expect(unfavourite_salmon.content.text).to eq 'account no longer favourites a status by status_account@remote'
    end

    it 'returns element whose rendered view triggers unfavourite when processed' do
      favourite = Fabricate(:favourite)
      unfavourite_salmon = OStatus::AtomSerializer.new.unfavourite_salmon(favourite)
      xml = OStatus::AtomSerializer.render(unfavourite_salmon)
      envelope = OStatus2::Salmon.new.pack(xml, favourite.account.keypair)

      ProcessInteractionService.new.call(envelope, favourite.status.account)
      expect { favourite.reload }.to raise_error ActiveRecord::RecordNotFound
    end
  end

  describe '#follow_salmon' do
    include_examples 'namespaces' do
      def serialize
        follow = Fabricate(:follow)
        OStatus::AtomSerializer.new.follow_salmon(follow)
      end
    end

    it 'returns entry element' do
      follow = Fabricate(:follow)
      follow_salmon = OStatus::AtomSerializer.new.follow_salmon(follow)
      expect(follow_salmon.name).to eq 'entry'
    end

    it 'appends id element with unique tag' do
      follow = Fabricate(:follow, created_at: '2000-01-01T00:00:00Z')
      follow_salmon = OStatus::AtomSerializer.new.follow_salmon(follow)
      expect(follow_salmon.id.text).to eq "tag:cb6e6126.ngrok.io,2000-01-01:objectId=#{follow.id}:objectType=Follow"
    end

    it 'appends author element with account' do
      account = Fabricate(:account, domain: nil, username: 'username')
      follow = Fabricate(:follow, account: account)

      follow_salmon = OStatus::AtomSerializer.new.follow_salmon(follow)

      expect(follow_salmon.author.id.text).to eq 'https://cb6e6126.ngrok.io/users/username'
    end

    it 'appends activity:object-type element with activity type' do
      follow = Fabricate(:follow)

      follow_salmon = OStatus::AtomSerializer.new.follow_salmon(follow)

      object_type = follow_salmon.nodes.find { |node| node.name == 'activity:object-type' }
      expect(object_type.text).to eq OStatus::TagManager::TYPES[:activity]
    end

    it 'appends activity:verb element with follow' do
      follow = Fabricate(:follow)

      follow_salmon = OStatus::AtomSerializer.new.follow_salmon(follow)

      verb = follow_salmon.nodes.find { |node| node.name == 'activity:verb' }
      expect(verb.text).to eq OStatus::TagManager::VERBS[:follow]
    end

    it 'appends activity:object element with target account' do
      target_account = Fabricate(:account, domain: 'domain.test', uri: 'https://domain.test/id')
      follow = Fabricate(:follow, target_account: target_account)

      follow_salmon = OStatus::AtomSerializer.new.follow_salmon(follow)

      object = follow_salmon.nodes.find { |node| node.name == 'activity:object' }
      expect(object.id.text).to eq 'https://domain.test/id'
    end

    it 'includes description' do
      account = Fabricate(:account, domain: nil, username: 'account')
      target_account = Fabricate(:account, domain: 'remote', username: 'target_account')
      follow = Fabricate(:follow, account: account, target_account: target_account)

      follow_salmon = OStatus::AtomSerializer.new.follow_salmon(follow)

      expect(follow_salmon.title.text).to eq 'account started following target_account@remote'
      expect(follow_salmon.content.text).to eq 'account started following target_account@remote'
    end

    it 'returns element whose rendered view triggers follow when processed' do
      follow = Fabricate(:follow)
      follow_salmon = OStatus::AtomSerializer.new.follow_salmon(follow)
      xml = OStatus::AtomSerializer.render(follow_salmon)
      follow.destroy!
      envelope = OStatus2::Salmon.new.pack(xml, follow.account.keypair)

      ProcessInteractionService.new.call(envelope, follow.target_account)

      expect(follow.account.following?(follow.target_account)).to be true
    end
  end

  describe '#unfollow_salmon' do
    include_examples 'namespaces' do
      def serialize
        follow = Fabricate(:follow)
        follow.destroy!
        OStatus::AtomSerializer.new.unfollow_salmon(follow)
      end
    end

    it 'returns entry element' do
      follow = Fabricate(:follow)
      follow.destroy!

      unfollow_salmon = OStatus::AtomSerializer.new.unfollow_salmon(follow)

      expect(unfollow_salmon.name).to eq 'entry'
    end

    it 'appends id element with unique tag' do
      follow = Fabricate(:follow)
      follow.destroy!

      time_before = Time.zone.now
      unfollow_salmon = OStatus::AtomSerializer.new.unfollow_salmon(follow)
      time_after = Time.zone.now

      expect(unfollow_salmon.id.text).to(
        eq(OStatus::TagManager.instance.unique_tag(time_before.utc, follow.id, 'Follow'))
          .or(eq(OStatus::TagManager.instance.unique_tag(time_after.utc, follow.id, 'Follow')))
      )
    end

    it 'appends title element with description' do
      account = Fabricate(:account, domain: nil, username: 'account')
      target_account = Fabricate(:account, domain: 'remote', username: 'target_account')
      follow = Fabricate(:follow, account: account, target_account: target_account)
      follow.destroy!

      unfollow_salmon = OStatus::AtomSerializer.new.unfollow_salmon(follow)

      expect(unfollow_salmon.title.text).to eq 'account is no longer following target_account@remote'
    end

    it 'appends content element with description' do
      account = Fabricate(:account, domain: nil, username: 'account')
      target_account = Fabricate(:account, domain: 'remote', username: 'target_account')
      follow = Fabricate(:follow, account: account, target_account: target_account)
      follow.destroy!

      unfollow_salmon = OStatus::AtomSerializer.new.unfollow_salmon(follow)

      expect(unfollow_salmon.content.text).to eq 'account is no longer following target_account@remote'
    end

    it 'appends author element with account' do
      account = Fabricate(:account, domain: nil, username: 'username')
      follow = Fabricate(:follow, account: account)
      follow.destroy!

      unfollow_salmon = OStatus::AtomSerializer.new.unfollow_salmon(follow)

      expect(unfollow_salmon.author.id.text).to eq 'https://cb6e6126.ngrok.io/users/username'
    end

    it 'appends activity:object-type element with activity type' do
      follow = Fabricate(:follow)
      follow.destroy!

      unfollow_salmon = OStatus::AtomSerializer.new.unfollow_salmon(follow)

      object_type = unfollow_salmon.nodes.find { |node| node.name == 'activity:object-type' }
      expect(object_type.text).to eq OStatus::TagManager::TYPES[:activity]
    end

    it 'appends activity:verb element with follow' do
      follow = Fabricate(:follow)
      follow.destroy!

      unfollow_salmon = OStatus::AtomSerializer.new.unfollow_salmon(follow)

      verb = unfollow_salmon.nodes.find { |node| node.name == 'activity:verb' }
      expect(verb.text).to eq OStatus::TagManager::VERBS[:unfollow]
    end

    it 'appends activity:object element with target account' do
      target_account = Fabricate(:account, domain: 'domain.test', uri: 'https://domain.test/id')
      follow = Fabricate(:follow, target_account: target_account)
      follow.destroy!

      unfollow_salmon = OStatus::AtomSerializer.new.unfollow_salmon(follow)

      object = unfollow_salmon.nodes.find { |node| node.name == 'activity:object' }
      expect(object.id.text).to eq 'https://domain.test/id'
    end

    it 'returns element whose rendered view triggers unfollow when processed' do
      follow = Fabricate(:follow)
      follow.destroy!
      unfollow_salmon = OStatus::AtomSerializer.new.unfollow_salmon(follow)
      xml = OStatus::AtomSerializer.render(unfollow_salmon)
      follow.account.follow!(follow.target_account)
      envelope = OStatus2::Salmon.new.pack(xml, follow.account.keypair)

      ProcessInteractionService.new.call(envelope, follow.target_account)

      expect(follow.account.following?(follow.target_account)).to be false
    end
  end

  describe '#follow_request_salmon' do
    include_examples 'namespaces' do
      def serialize
        follow_request = Fabricate(:follow_request)
        OStatus::AtomSerializer.new.follow_request_salmon(follow_request)
      end
    end

    context do
      def serialize(follow_request)
        OStatus::AtomSerializer.new.follow_request_salmon(follow_request)
      end

      it_behaves_like 'follow request salmon'

      it 'appends id element with unique tag' do
        follow_request = Fabricate(:follow_request, created_at: '2000-01-01T00:00:00Z')
        follow_request_salmon = serialize(follow_request)
        expect(follow_request_salmon.id.text).to eq "tag:cb6e6126.ngrok.io,2000-01-01:objectId=#{follow_request.id}:objectType=FollowRequest"
      end

      it 'appends title element with description' do
        account = Fabricate(:account, domain: nil, username: 'account')
        target_account = Fabricate(:account, domain: 'remote', username: 'target_account')
        follow_request = Fabricate(:follow_request, account: account, target_account: target_account)
        follow_request_salmon = serialize(follow_request)
        expect(follow_request_salmon.title.text).to eq 'account requested to follow target_account@remote'
      end

      it 'returns element whose rendered view triggers follow request when processed' do
        follow_request = Fabricate(:follow_request)
        follow_request_salmon = serialize(follow_request)
        xml = OStatus::AtomSerializer.render(follow_request_salmon)
        envelope = OStatus2::Salmon.new.pack(xml, follow_request.account.keypair)
        follow_request.destroy!

        ProcessInteractionService.new.call(envelope, follow_request.target_account)

        expect(follow_request.account.requested?(follow_request.target_account)).to eq true
      end
    end
  end

  describe '#authorize_follow_request_salmon' do
    include_examples 'namespaces' do
      def serialize
        follow_request = Fabricate(:follow_request)
        OStatus::AtomSerializer.new.authorize_follow_request_salmon(follow_request)
      end
    end

    it_behaves_like 'follow request salmon' do
      def serialize(follow_request)
        authorize_follow_request_salmon = OStatus::AtomSerializer.new.authorize_follow_request_salmon(follow_request)
        authorize_follow_request_salmon.nodes.find { |node| node.name == 'activity:object' }
      end
    end

    it 'appends id element with unique tag' do
      follow_request = Fabricate(:follow_request)

      time_before = Time.zone.now
      authorize_follow_request_salmon = OStatus::AtomSerializer.new.authorize_follow_request_salmon(follow_request)
      time_after = Time.zone.now

      expect(authorize_follow_request_salmon.id.text).to(
        eq(OStatus::TagManager.instance.unique_tag(time_before.utc, follow_request.id, 'FollowRequest'))
          .or(eq(OStatus::TagManager.instance.unique_tag(time_after.utc, follow_request.id, 'FollowRequest')))
      )
    end

    it 'appends title element with description' do
      account = Fabricate(:account, domain: 'remote', username: 'account')
      target_account = Fabricate(:account, domain: nil, username: 'target_account')
      follow_request = Fabricate(:follow_request, account: account, target_account: target_account)

      authorize_follow_request_salmon = OStatus::AtomSerializer.new.authorize_follow_request_salmon(follow_request)

      expect(authorize_follow_request_salmon.title.text).to eq 'target_account authorizes follow request by account@remote'
    end

    it 'appends activity:object-type element with activity type' do
      follow_request = Fabricate(:follow_request)

      authorize_follow_request_salmon = OStatus::AtomSerializer.new.authorize_follow_request_salmon(follow_request)

      object_type = authorize_follow_request_salmon.nodes.find { |node| node.name == 'activity:object-type' }
      expect(object_type.text).to eq OStatus::TagManager::TYPES[:activity]
    end

    it 'appends activity:verb element with authorize' do
      follow_request = Fabricate(:follow_request)

      authorize_follow_request_salmon = OStatus::AtomSerializer.new.authorize_follow_request_salmon(follow_request)

      verb = authorize_follow_request_salmon.nodes.find { |node| node.name == 'activity:verb' }
      expect(verb.text).to eq OStatus::TagManager::VERBS[:authorize]
    end

    it 'returns element whose rendered view creates follow from follow request when processed' do
      follow_request = Fabricate(:follow_request)
      authorize_follow_request_salmon = OStatus::AtomSerializer.new.authorize_follow_request_salmon(follow_request)
      xml = OStatus::AtomSerializer.render(authorize_follow_request_salmon)
      envelope = OStatus2::Salmon.new.pack(xml, follow_request.target_account.keypair)

      ProcessInteractionService.new.call(envelope, follow_request.account)

      expect(follow_request.account.following?(follow_request.target_account)).to eq true
      expect { follow_request.reload }.to raise_error ActiveRecord::RecordNotFound
    end
  end

  describe '#reject_follow_request_salmon' do
    include_examples 'namespaces' do
      def serialize
        follow_request = Fabricate(:follow_request)
        OStatus::AtomSerializer.new.reject_follow_request_salmon(follow_request)
      end
    end

    it_behaves_like 'follow request salmon' do
      def serialize(follow_request)
        reject_follow_request_salmon = OStatus::AtomSerializer.new.reject_follow_request_salmon(follow_request)
        reject_follow_request_salmon.nodes.find { |node| node.name == 'activity:object' }
      end
    end

    it 'appends id element with unique tag' do
      follow_request = Fabricate(:follow_request)

      time_before = Time.zone.now
      reject_follow_request_salmon = OStatus::AtomSerializer.new.reject_follow_request_salmon(follow_request)
      time_after = Time.zone.now

      expect(reject_follow_request_salmon.id.text).to(
        eq(OStatus::TagManager.instance.unique_tag(time_before.utc, follow_request.id, 'FollowRequest'))
          .or(OStatus::TagManager.instance.unique_tag(time_after.utc, follow_request.id, 'FollowRequest'))
      )
    end

    it 'appends title element with description' do
      account = Fabricate(:account, domain: 'remote', username: 'account')
      target_account = Fabricate(:account, domain: nil, username: 'target_account')
      follow_request = Fabricate(:follow_request, account: account, target_account: target_account)
      reject_follow_request_salmon = OStatus::AtomSerializer.new.reject_follow_request_salmon(follow_request)
      expect(reject_follow_request_salmon.title.text).to eq 'target_account rejects follow request by account@remote'
    end

    it 'appends activity:object-type element with activity type' do
      follow_request = Fabricate(:follow_request)
      reject_follow_request_salmon = OStatus::AtomSerializer.new.reject_follow_request_salmon(follow_request)
      object_type = reject_follow_request_salmon.nodes.find { |node| node.name == 'activity:object-type' }
      expect(object_type.text).to eq OStatus::TagManager::TYPES[:activity]
    end

    it 'appends activity:verb element with authorize' do
      follow_request = Fabricate(:follow_request)
      reject_follow_request_salmon = OStatus::AtomSerializer.new.reject_follow_request_salmon(follow_request)
      verb = reject_follow_request_salmon.nodes.find { |node| node.name == 'activity:verb' }
      expect(verb.text).to eq OStatus::TagManager::VERBS[:reject]
    end

    it 'returns element whose rendered view deletes follow request when processed' do
      follow_request = Fabricate(:follow_request)
      reject_follow_request_salmon = OStatus::AtomSerializer.new.reject_follow_request_salmon(follow_request)
      xml = OStatus::AtomSerializer.render(reject_follow_request_salmon)
      envelope = OStatus2::Salmon.new.pack(xml, follow_request.target_account.keypair)

      ProcessInteractionService.new.call(envelope, follow_request.account)

      expect(follow_request.account.following?(follow_request.target_account)).to eq false
      expect { follow_request.reload }.to raise_error ActiveRecord::RecordNotFound
    end
  end

  describe '#object' do
    include_examples 'status attributes' do
      def serialize(status)
        OStatus::AtomSerializer.new.object(status)
      end
    end

    it 'returns activity:object element' do
      status = Fabricate(:status)
      object = OStatus::AtomSerializer.new.object(status)
      expect(object.name).to eq 'activity:object'
    end

    it 'appends id element with URL for status' do
      status = Fabricate(:status, created_at: '2000-01-01T00:00:00Z')
      object = OStatus::AtomSerializer.new.object(status)
      expect(object.id.text).to eq "https://cb6e6126.ngrok.io/users/#{status.account.to_param}/statuses/#{status.id}"
    end

    it 'appends published element with created date' do
      status = Fabricate(:status, created_at: '2000-01-01T00:00:00Z')
      object = OStatus::AtomSerializer.new.object(status)
      expect(object.published.text).to eq '2000-01-01T00:00:00Z'
    end

    it 'appends updated element with updated date' do
      status = Fabricate(:status)
      status.updated_at = '2000-01-01T00:00:00Z'
      object = OStatus::AtomSerializer.new.object(status)
      expect(object.updated.text).to eq '2000-01-01T00:00:00Z'
    end

    it 'appends title element with title' do
      account = Fabricate(:account, username: 'username')
      status = Fabricate(:status, account: account)

      object = OStatus::AtomSerializer.new.object(status)

      expect(object.title.text).to eq 'New status by username'
    end

    it 'appends author element with account' do
      account = Fabricate(:account, username: 'username')
      status = Fabricate(:status, account: account)

      entry = OStatus::AtomSerializer.new.object(status)

      expect(entry.author.id.text).to eq 'https://cb6e6126.ngrok.io/users/username'
    end

    it 'appends activity:object-type element with object type' do
      status = Fabricate(:status)

      entry = OStatus::AtomSerializer.new.object(status)

      object_type = entry.nodes.find { |node| node.name == 'activity:object-type' }
      expect(object_type.text).to eq OStatus::TagManager::TYPES[:note]
    end

    it 'appends activity:verb element with verb' do
      status = Fabricate(:status)

      entry = OStatus::AtomSerializer.new.object(status)

      object_type = entry.nodes.find { |node| node.name == 'activity:verb' }
      expect(object_type.text).to eq OStatus::TagManager::VERBS[:post]
    end

    it 'appends link element for an alternative' do
      account = Fabricate(:account, username: 'username')
      status = Fabricate(:status, account: account)

      entry = OStatus::AtomSerializer.new.object(status)

      link = entry.nodes.find { |node| node.name == 'link' && node[:rel] == 'alternate' && node[:type] == 'text/html' }
      expect(link[:type]).to eq 'text/html'
      expect(link[:href]).to eq "https://cb6e6126.ngrok.io/@username/#{status.id}"
    end

    it 'appends thr:in-reply-to element if it is a reply and thread is not nil' do
      account = Fabricate(:account, username: 'username')
      thread = Fabricate(:status, account: account, created_at: '2000-01-01T00:00:00Z')
      reply = Fabricate(:status, thread: thread)

      entry = OStatus::AtomSerializer.new.object(reply)

      in_reply_to = entry.nodes.find { |node| node.name == 'thr:in-reply-to' }
      expect(in_reply_to.ref).to eq "https://cb6e6126.ngrok.io/users/#{thread.account.to_param}/statuses/#{thread.id}"
      expect(in_reply_to.href).to eq "https://cb6e6126.ngrok.io/@username/#{thread.id}"
    end

    it 'does not append thr:in-reply-to element if thread is nil' do
      status = Fabricate(:status, thread: nil)
      entry = OStatus::AtomSerializer.new.object(status)
      entry.nodes.each { |node| expect(node.name).not_to eq 'thr:in-reply-to' }
    end

    it 'does not append ostatus:conversation element if conversation_id is nil' do
      status = Fabricate.build(:status, conversation_id: nil)
      status.save!(validate: false)

      entry = OStatus::AtomSerializer.new.object(status)

      entry.nodes.each { |node| expect(node.name).not_to eq 'ostatus:conversation' }
    end

    it 'appends ostatus:conversation element if conversation_id is not nil' do
      status = Fabricate(:status)
      status.conversation.update!(created_at: '2000-01-01T00:00:00Z')

      entry = OStatus::AtomSerializer.new.object(status)

      conversation = entry.nodes.find { |node| node.name == 'ostatus:conversation' }
      expect(conversation[:ref]).to eq "tag:cb6e6126.ngrok.io,2000-01-01:objectId=#{status.conversation.id}:objectType=Conversation"
    end
  end
end
