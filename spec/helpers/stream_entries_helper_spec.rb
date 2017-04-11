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

  describe '#avatar_for_status_url' do
    pending
  end

  describe '#entry_classes' do
    pending
  end

  describe '#relative_time' do
    pending
  end

  describe '#reblogged_by_me_class' do
    pending
  end

  describe '#favourited_by_me_class' do
    pending
  end
end
