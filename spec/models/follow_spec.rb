require 'rails_helper'

RSpec.describe Follow, type: :model do
  let(:alice) { Fabricate(:account, username: 'alice') }
  let(:bob)   { Fabricate(:account, username: 'bob') }

  describe 'recent' do
    it 'sorts so that more recent follows comes earlier' do
      follow0 = Follow.create!(account: alice, target_account: bob)
      follow1 = Follow.create!(account: bob, target_account: alice)

      a = Follow.recent.to_a

      expect(a.size).to eq 2
      expect(a[0]).to eq follow1
      expect(a[1]).to eq follow0
    end
  end
end
