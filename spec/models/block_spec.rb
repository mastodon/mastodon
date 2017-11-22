require 'rails_helper'

RSpec.describe Block, type: :model do
  it 'removes blocking cache after creation' do
    account = Fabricate(:account)
    target_account = Fabricate(:account)
    Rails.cache.write("exclude_account_ids_for:#{account.id}", [])
    Rails.cache.write("exclude_account_ids_for:#{target_account.id}", [])

    Block.create!(account: account, target_account: target_account)

    expect(Rails.cache.exist?("exclude_account_ids_for:#{account.id}")).to eq false
    expect(Rails.cache.exist?("exclude_account_ids_for:#{target_account.id}")).to eq false
  end

  it 'removes blocking cache after destruction' do
    account = Fabricate(:account)
    target_account = Fabricate(:account)
    block = Block.create!(account: account, target_account: target_account)
    Rails.cache.write("exclude_account_ids_for:#{account.id}", [target_account.id])
    Rails.cache.write("exclude_account_ids_for:#{target_account.id}", [account.id])

    block.destroy!

    expect(Rails.cache.exist?("exclude_account_ids_for:#{account.id}")).to eq false
    expect(Rails.cache.exist?("exclude_account_ids_for:#{target_account.id}")).to eq false
  end
end
