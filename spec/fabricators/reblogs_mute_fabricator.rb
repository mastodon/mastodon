Fabricator(:reblogs_mute) do
  account
  target_account { Fabricate(:account) }
end
