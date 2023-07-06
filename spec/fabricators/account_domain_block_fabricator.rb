# frozen_string_literal: true

Fabricator(:account_domain_block) do
  account { Fabricate.build(:account) }
  domain 'example.com'
end
