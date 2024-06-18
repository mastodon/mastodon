# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CircleAccount do
  it 'creates a list account after creation' do
    circle = Fabricate(:circle)
    account = Fabricate(:account)
    Fabricate(:follow, account: account, target_account: circle.account)
    Fabricate(:follow, account: circle.account, target_account: account)
    Fabricate(:circle_account, circle: circle, account: account)
    expect(circle.list.accounts).to include(account)
  end

  it 'removes a list account after destruction' do
    circle = Fabricate(:circle)
    account = Fabricate(:account)
    Fabricate(:follow, account: account, target_account: circle.account)
    Fabricate(:follow, account: circle.account, target_account: account)
    circle_account = Fabricate(:circle_account, circle: circle, account: account)

    circle_account.destroy
    expect(circle.list.accounts).to_not include(account)
  end
end
