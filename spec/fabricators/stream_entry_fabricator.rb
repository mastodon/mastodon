Fabricator(:stream_entry) do
  account
  activity { Fabricate(:status) }
  hidden { [true, false].sample }
end
