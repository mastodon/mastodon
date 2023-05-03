# frozen_string_literal: true

Fabricator('Admin::ActionLog') do
  account
  action  'MyString'
  target  nil
end
