# frozen_string_literal: true

Fabricator(:report_note) do
  report { Fabricate.build(:report) }
  account { Fabricate.build(:account) }
  content { 'Report note content' }
end
