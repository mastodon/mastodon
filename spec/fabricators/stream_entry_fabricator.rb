Fabricator(:stream_entry) do
  initialize_with { Fabricate(:status).stream_entry }
end
