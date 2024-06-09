# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccountDomainBlock do
  let(:account) { Fabricate(:account) }

  it 'removes blocking cache after creation' do
    Rails.cache.write("exclude_domains_for:#{account.id}", 'a.domain.already.blocked')

    Fabricate(:account_domain_block, account: account, domain: 'a.domain.blocked.later')

    expect(account_has_exclude_domains_cache?).to be false
  end

  it 'removes blocking cache after destruction' do
    block = Fabricate(:account_domain_block, account: account, domain: 'domain')
    Rails.cache.write("exclude_domains_for:#{account.id}", 'domain')

    block.destroy!

    expect(account_has_exclude_domains_cache?).to be false
  end

  def account_has_exclude_domains_cache?
    Rails.cache.exist?("exclude_domains_for:#{account.id}")
  end
end
