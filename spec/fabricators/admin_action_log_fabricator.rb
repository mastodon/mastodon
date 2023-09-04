# frozen_string_literal: true

Fabricator('Admin::ActionLog') do
  account { Fabricate.build(:account) }
  action  'MyString'
  target  nil
end
