# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccountDomainBlock do
  it 'removes blocking cache after creation' do
    account = Fabricate(:account)
    Rails.cache.write("exclude_domains_for:#{account.id}", 'a.domain.already.blocked')

    described_class.create!(account: account, domain: 'a.domain.blocked.later')

    expect(Rails.cache.exist?("exclude_domains_for:#{account.id}")).to be false
  end

  it 'removes blocking cache after destruction' do
    account = Fabricate(:account)
    block = described_class.create!(account: account, domain: 'domain')
    Rails.cache.write("exclude_domains_for:#{account.id}", 'domain')

    block.destroy!

    expect(Rails.cache.exist?("exclude_domains_for:#{account.id}")).to be false
  end
end
