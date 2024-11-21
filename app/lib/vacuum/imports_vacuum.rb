# frozen_string_literal: true

class Vacuum::ImportsVacuum
  def perform
    clean_unconfirmed_imports!
    clean_old_imports!
  end

  private

  def clean_unconfirmed_imports!
    BulkImport
      .confirmation_missed
      .in_batches
      .delete_all
  end

  def clean_old_imports!
    BulkImport
      .archival_completed
      .in_batches
      .delete_all
  end
end
