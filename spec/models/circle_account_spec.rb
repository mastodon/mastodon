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

  it 'does not throw an error if list account is not able to be created due to lack of following' do
    circle = Fabricate(:circle)
    account = Fabricate(:account)
    Fabricate(:follow, account: account, target_account: circle.account)
    expect { Fabricate(:circle_account, circle: circle, account: account) }.to_not raise_error
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

  it 'does not throw an error if the list account to be removed after destruction does not exist' do
    circle = Fabricate(:circle)
    account = Fabricate(:account)
    Fabricate(:follow, account: account, target_account: circle.account)
    circle_account = Fabricate(:circle_account, circle: circle, account: account)
    expect(circle.list.accounts).to_not include(account)

    circle_account.destroy
  end
end
