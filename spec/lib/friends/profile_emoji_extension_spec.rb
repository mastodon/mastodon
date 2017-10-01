require 'rails_helper'

RSpec.describe Friends::ProfileEmojiExtension do
  let(:klass) do
    class Foo
      include Friends::ProfileEmojiExtension
    end
  end
  let(:target) { klass.new }
  let(:account1) { Fabricate(:account) }

  describe '#get_profile_emojis' do
    let(:text) { ":@#{account1.username}:" }
    it do
      res = target.get_profile_emojis(text, 'unko')
      expect(res.length).to eq 1
    end
  end

  describe '#scan_profile_emojis_from_text' do
    let(:account2) { Fabricate(:account) }
    let(:account3) { Fabricate(:account) }
    let(:text) { ":@#{account1.username}: @#{account2.username} :@#{account3.username} :@#{account1.username}:" }
    it do
      emojis = target.send(:scan_profile_emojis_from_text, text)
      expect(emojis.length).to eq 1
      emojis.first.tap do |emoji|
        expect(emoji[:account_id]).to eq account1.id
      end
    end
  end
end
