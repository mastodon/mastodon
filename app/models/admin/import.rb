# frozen_string_literal: true

# A non-activerecord helper class for csv upload
class Admin::Import
  include ActiveModel::Model

  ROWS_PROCESSING_LIMIT = 20_000

  attr_accessor :data

  validates :data, presence: true
  validate :validate_data

  def data_file_name
    data.original_filename
  end

  private

  def validate_data
    return if data.blank?

    csv_data = CSV.read(data.path, encoding: 'UTF-8')

    row_count  = csv_data.size
    row_count -= 1 if csv_data.first&.first == '#domain'

    errors.add(:data, I18n.t('imports.errors.over_rows_processing_limit', count: ROWS_PROCESSING_LIMIT)) if row_count > ROWS_PROCESSING_LIMIT
  rescue CSV::MalformedCSVError => e
    errors.add(:data, I18n.t('imports.errors.invalid_csv_file', error: e.message))
  end
end
