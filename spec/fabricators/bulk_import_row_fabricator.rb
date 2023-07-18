# frozen_string_literal: true

Fabricator(:bulk_import_row) do
  bulk_import { Fabricate.build(:bulk_import) }
  data ''
end
