# frozen_string_literal: true

Fabricator(:bulk_import) do
  type            1
  state           1
  total_items     1
  processed_items 1
  imported_items  1
  finished_at     '2022-11-18 14:55:07'
  overwrite       false
  account { Fabricate.build(:account) }
end
