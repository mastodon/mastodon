# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Block do
  describe 'validations' do
    it { is_expected.to belong_to(:account).required }
    it { is_expected.to belong_to(:target_account).required }
  end

  it 'removes blocking cache after creation' do
    account = Fabricate(:account)
    target_account = Fabricate(:account)
    Rails.cache.write("exclude_account_ids_for:#{account.id}", [])
    Rails.cache.write("exclude_account_ids_for:#{target_account.id}", [])

    described_class.create!(account: account, target_account: target_account)

    expect(Rails.cache.exist?("exclude_account_ids_for:#{account.id}")).to be false
    expect(Rails.cache.exist?("exclude_account_ids_for:#{target_account.id}")).to be false
  end

  it 'removes blocking cache after destruction' do
    account = Fabricate(:account)
    target_account = Fabricate(:account)
    block = described_class.create!(account: account, target_account: target_account)
    Rails.cache.write("exclude_account_ids_for:#{account.id}", [target_account.id])
    Rails.cache.write("exclude_account_ids_for:#{target_account.id}", [account.id])

    block.destroy!

    expect(Rails.cache.exist?("exclude_account_ids_for:#{account.id}")).to be false
    expect(Rails.cache.exist?("exclude_account_ids_for:#{target_account.id}")).to be false
  end
end
