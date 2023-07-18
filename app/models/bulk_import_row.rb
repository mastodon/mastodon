# frozen_string_literal: true

# == Schema Information
#
# Table name: bulk_import_rows
#
#  id             :bigint(8)        not null, primary key
#  bulk_import_id :bigint(8)        not null
#  data           :jsonb
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
class BulkImportRow < ApplicationRecord
  belongs_to :bulk_import
end
