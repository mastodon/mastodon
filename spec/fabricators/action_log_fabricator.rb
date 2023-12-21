# frozen_string_literal: true

Fabricator(:action_log, from: Admin::ActionLog) do
  account { Fabricate.build(:account) }
  action  'MyString'
  target  nil
end
