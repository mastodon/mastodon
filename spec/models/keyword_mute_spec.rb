require 'rails_helper'

RSpec.describe KeywordMute, type: :model do
  describe '.matches?' do
    let(:alice)  { Fabricate(:account, username: 'alice').tap(&:save!) }
    let(:status) { Fabricate(:status, account: alice).tap(&:save!) }
    let(:keyword_mute) { Fabricate(:keyword_mute, account: alice, keyword: 'take').tap(&:save!) }

    it 'returns true if any keyword in the set matches the status text' do
      status.update_attribute(:text, 'This is a hot take')

      expect(KeywordMute.where(account: alice).matches?(status.text)).to be_truthy
    end

    it 'returns false if no keyword in the set matches the status text'

    describe 'matching' do
      it 'is case-insensitive'
    end
  end
end
