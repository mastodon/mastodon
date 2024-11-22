# frozen_string_literal: true

Fabricator(:account_domain_block) do
  account { Fabricate.build(:account) }
  domain { sequence { |n| "host-#{n}.example" } }
end
