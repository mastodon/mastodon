Fabricator(:follow_request) do
  account
  target_account { Fabricate(:account, locked: true) }
end
