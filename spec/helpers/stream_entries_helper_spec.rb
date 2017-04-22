require 'rails_helper'

RSpec.describe StreamEntriesHelper, type: :helper do
  describe '#display_name' do
    it 'uses the display name when it exists' do
      account = Account.new(display_name: "Display", username: "Username")

      expect(helper.display_name(account)).to eq "Display"
    end

    it 'uses the username when display name is nil' do
      account = Account.new(display_name: nil, username: "Username")

      expect(helper.display_name(account)).to eq "Username"
    end
  end

  describe '#rtl?' do
    it 'is false if text is empty' do
      expect(helper).not_to be_rtl ''
    end

    it 'is false if there are no right to left characters' do
      expect(helper).not_to be_rtl 'hello world'
    end

    it 'is false if right to left characters are fewer than 1/3 of total text' do
      expect(helper).not_to be_rtl 'hello ݟ world'
    end

    it 'is true if right to left characters are greater than 1/3 of total text' do
      expect(helper).to be_rtl 'aaݟ'
    end
  end
end
