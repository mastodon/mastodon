Fabricator(:status_pin) do
  account
  status { |attrs| Fabricate(:status, account: attrs[:account], visibility: :public) }
end
