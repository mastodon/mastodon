# frozen_string_literal: true

Fabricator(:status_pin) do
  account { Fabricate.build(:account) }
  status { |attrs| Fabricate.build(:status, account: attrs[:account], visibility: :public) }
end
