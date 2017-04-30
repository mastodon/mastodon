require 'rails_helper'

RSpec.describe AtomSerializer do
  let(:author)   { Fabricate(:account, username: 'Sombra', display_name: '1337 haxxor') }
  let(:receiver) { Fabricate(:account, username: 'Symmetra') }

  before do
    stub_request(:get, "https://cb6e6126.ngrok.io/avatars/original/missing.png").to_return(status: 404)
    stub_request(:get, "https://cb6e6126.ngrok.io/headers/original/missing.png").to_return(status: 404)
  end

  describe '#author' do
    it 'returns dumpable XML with emojis' do
      account = Fabricate(:account, display_name: '💩')
      xml     = AtomSerializer.render(AtomSerializer.new.author(account))

      expect(xml).to be_a String
      expect(xml).to match(/<poco:displayName>💩<\/poco:displayName>/)
    end

    it 'returns dumpable XML with invalid characters like \b and \v' do
      account = Fabricate(:account, display_name: "im l33t\b haxo\b\vr")
      xml     = AtomSerializer.render(AtomSerializer.new.author(account))

      expect(xml).to be_a String
      expect(xml).to match(/<poco:displayName>im l33t haxor<\/poco:displayName>/)
    end
  end

  describe '#entry' do
    describe 'with deleted status' do
      let(:entry) do
        status = Fabricate(:status, account: author, text: 'boop')
        entry  = status.stream_entry
        status.destroy
        entry
      end

      it 'returns dumpable XML' do
        xml = AtomSerializer.render(AtomSerializer.new.entry(entry, true))
        expect(xml).to be_a String
        expect(xml).to match(/<id>#{TagManager.instance.unique_tag(entry.created_at, entry.activity_id, 'Status')}<\/id>/)
      end

      it 'triggers delete when processed' do
        status  = double(id: entry.activity_id)
        service = double

        allow(Status).to receive(:find_by).and_return(status)
        allow(RemoveStatusService).to receive(:new).and_return(service)
        allow(service).to receive(:call)

        xml = AtomSerializer.render(AtomSerializer.new.entry(entry, true))
        ProcessFeedService.new.call(xml, author)

        expect(service).to have_received(:call).with(status)
      end
    end

    describe 'with reblog of local user' do
      it 'returns dumpable XML'
      it 'creates a reblog'
    end

    describe 'with reblog of 3rd party user' do
      it 'returns dumpable XML'
      it 'creates a reblog with correct author'
    end
  end

  describe '#follow_salmon' do
    let(:xml) do
      follow = Fabricate(:follow, account: author, target_account: receiver)
      xml    = AtomSerializer.render(AtomSerializer.new.follow_salmon(follow))
      follow.destroy
      xml
    end

    it 'returns dumpable XML' do
      expect(xml).to be_a String
    end

    it 'triggers follow when processed' do
      envelope = OStatus2::Salmon.new.pack(xml, author.keypair)
      ProcessInteractionService.new.call(envelope, receiver)
      expect(author.following?(receiver)).to be true
    end
  end

  describe '#unfollow_salmon' do
    let(:xml) do
      follow = Fabricate(:follow, account: author, target_account: receiver)
      follow.destroy
      xml = AtomSerializer.render(AtomSerializer.new.unfollow_salmon(follow))
      author.follow!(receiver)
      xml
    end

    it 'returns dumpable XML' do
      expect(xml).to be_a String
    end

    it 'triggers unfollow when processed' do
      envelope = OStatus2::Salmon.new.pack(xml, author.keypair)
      ProcessInteractionService.new.call(envelope, receiver)
      expect(author.following?(receiver)).to be false
    end
  end

  describe '#favourite_salmon' do
    let(:status) { Fabricate(:status, account: receiver, text: 'Everything by design.') }

    let(:xml) do
      favourite = Fabricate(:favourite, account: author, status: status)
      xml       = AtomSerializer.render(AtomSerializer.new.favourite_salmon(favourite))
      favourite.destroy
      xml
    end

    it 'returns dumpable XML' do
      expect(xml).to be_a String
    end

    it 'triggers favourite when processed' do
      envelope = OStatus2::Salmon.new.pack(xml, author.keypair)
      ProcessInteractionService.new.call(envelope, receiver)
      expect(author.favourited?(status)).to be true
    end
  end

  describe '#unfavourite_salmon' do
    let(:status) { Fabricate(:status, account: receiver, text: 'Perfect harmony.') }

    let(:xml) do
      favourite = Fabricate(:favourite, account: author, status: status)
      favourite.destroy
      xml = AtomSerializer.render(AtomSerializer.new.unfavourite_salmon(favourite))
      Fabricate(:favourite, account: author, status: status)
      xml
    end

    it 'returns dumpable XML' do
      expect(xml).to be_a String
    end

    it 'triggers unfavourite when processed' do
      envelope = OStatus2::Salmon.new.pack(xml, author.keypair)
      ProcessInteractionService.new.call(envelope, receiver)
      expect(author.favourited?(status)).to be false
    end
  end

  describe '#block_salmon' do
    let(:xml) do
      block = Fabricate(:block, account: author, target_account: receiver)
      xml   = AtomSerializer.render(AtomSerializer.new.block_salmon(block))
      block.destroy
      xml
    end

    it 'returns dumpable XML' do
      expect(xml).to be_a String
    end

    it 'triggers block when processed' do
      envelope = OStatus2::Salmon.new.pack(xml, author.keypair)
      ProcessInteractionService.new.call(envelope, receiver)
      expect(author.blocking?(receiver)).to be true
    end
  end

  describe '#unblock_salmon' do
    let(:xml) do
      block = Fabricate(:block, account: author, target_account: receiver)
      block.destroy
      xml = AtomSerializer.render(AtomSerializer.new.unblock_salmon(block))
      author.block!(receiver)
      xml
    end

    it 'returns dumpable XML' do
      expect(xml).to be_a String
    end

    it 'triggers unblock when processed' do
      envelope = OStatus2::Salmon.new.pack(xml, author.keypair)
      ProcessInteractionService.new.call(envelope, receiver)
      expect(author.blocking?(receiver)).to be false
    end
  end

  describe '#follow_request_salmon' do
    it 'returns dumpable XML'
    it 'triggers follow request when processed'
  end

  describe '#authorize_follow_request_salmon' do
    it 'returns dumpable XML'
    it 'creates follow from follow request when processed'
  end

  describe '#reject_follow_request_salmon' do
    it 'returns dumpable XML'
    it 'deletes follow request when processed'
  end
end
