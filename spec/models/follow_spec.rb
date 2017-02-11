require 'rails_helper'

RSpec.describe Follow, type: :model do
  let(:alice) { Fabricate(:account, username: 'alice') }
  let(:bob)   { Fabricate(:account, username: 'bob') }

  subject { Follow.new(account: alice, target_account: bob) }
end
