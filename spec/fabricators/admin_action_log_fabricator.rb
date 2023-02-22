# frozen_string_literal: true

Fabricator('Admin::ActionLog') do
  account nil
  action  'MyString'
  target  nil
end
