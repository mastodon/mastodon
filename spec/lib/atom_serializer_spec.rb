require 'rails_helper'

RSpec.describe AtomSerializer do
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
end
