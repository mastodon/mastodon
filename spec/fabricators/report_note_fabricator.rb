Fabricator(:report_note) do
  report
  account { Fabricate(:account) }
  content "Test Content"
end
