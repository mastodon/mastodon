# frozen_string_literal: true

# == Schema Information
#
# Table name: bulk_imports
#
#  id                :bigint(8)        not null, primary key
#  type              :integer          not null
#  state             :integer          not null
#  total_items       :integer          default(0), not null
#  imported_items    :integer          default(0), not null
#  processed_items   :integer          default(0), not null
#  finished_at       :datetime
#  overwrite         :boolean          default(FALSE), not null
#  likely_mismatched :boolean          default(FALSE), not null
#  original_filename :string           default(""), not null
#  account_id        :bigint(8)        not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
class BulkImport < ApplicationRecord
  self.inheritance_column = false

  belongs_to :account
  has_many :rows, class_name: 'BulkImportRow', inverse_of: :bulk_import, dependent: :delete_all

  enum type: {
    following: 0,
    blocking: 1,
    muting: 2,
    domain_blocking: 3,
    bookmarks: 4,
    lists: 5,
  }

  enum state: {
    unconfirmed: 0,
    scheduled: 1,
    in_progress: 2,
    finished: 3,
  }

  validates :type, presence: true

  def self.progress!(bulk_import_id, imported: false)
    # Use `increment_counter` so that the incrementation is done atomically in the database
    BulkImport.increment_counter(:processed_items, bulk_import_id) # rubocop:disable Rails/SkipsModelValidations
    BulkImport.increment_counter(:imported_items, bulk_import_id) if imported # rubocop:disable Rails/SkipsModelValidations

    # Since the incrementation has been done atomically, concurrent access to `bulk_import` is now bening
    bulk_import = BulkImport.find(bulk_import_id)
    bulk_import.update!(state: :finished, finished_at: Time.now.utc) if bulk_import.processed_items == bulk_import.total_items
  end
end
