require 'rails_helper'

RSpec.describe Favourite, type: :model do
  let(:alice)  { Fabricate(:account, username: 'alice') }
  let(:bob)    { Fabricate(:account, username: 'bob') }
  let(:status) { Fabricate(:status, account: bob) }

  subject { Favourite.new(account: alice, status: status) }
end
