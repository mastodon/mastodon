# frozen_string_literal: true

Fabricator(:status_edit) do
  account { Fabricate.build(:account) }
  status { Fabricate.build(:status) }
  poll_options { |attrs| attrs[:poll_options] }
end
