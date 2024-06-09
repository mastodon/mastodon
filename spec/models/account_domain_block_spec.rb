# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccountDomainBlock do
  let(:account) { Fabricate(:account) }

  it 'removes blocking cache after creation' do
    Rails.cache.write("exclude_domains_for:#{account.id}", 'a.domain.already.blocked')

    expect { build_account_domain_block('a.domain.blocked.later') }
      .to change { account_has_exclude_domains_cache? }.to(false)
  end

  it 'removes blocking cache after destruction' do
    block = build_account_domain_block('domain')
    Rails.cache.write("exclude_domains_for:#{account.id}", 'domain')

    expect { block.destroy! }
      .to change { account_has_exclude_domains_cache? }.to(false)
  end

  private

  def build_account_domain_block(domain)
    Fabricate(:account_domain_block, account: account, domain: domain)
  end

  def account_has_exclude_domains_cache?
    Rails.cache.exist?("exclude_domains_for:#{account.id}")
  end
end
