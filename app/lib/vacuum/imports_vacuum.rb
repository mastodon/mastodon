# frozen_string_literal: true

class Vacuum::ImportsVacuum
  def perform
    clean_unconfirmed_imports!
    clean_old_imports!
  end

  private

  def clean_unconfirmed_imports!
    BulkImport.state_unconfirmed.where('created_at <= ?', 10.minutes.ago).reorder(nil).in_batches.delete_all
  end

  def clean_old_imports!
    BulkImport.where('created_at <= ?', 1.week.ago).reorder(nil).in_batches.delete_all
  end
end
