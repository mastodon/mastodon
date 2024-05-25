# frozen_string_literal: true

require 'csv'

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

  def csv_rows
    csv_data.rewind

    csv_data.take(ROWS_PROCESSING_LIMIT + 1)
  end

  private

  def csv_data
    return @csv_data if defined?(@csv_data)

    csv_converter = lambda do |field, field_info|
      case field_info.header
      when '#domain', '#public_comment'
        field&.strip
      when '#severity'
        field&.strip&.to_sym
      when '#reject_media', '#reject_reports', '#obfuscate'
        ActiveModel::Type::Boolean.new.cast(field)
      else
        field
      end
    end

    @csv_data = CSV.open(data.path, encoding: 'UTF-8', skip_blanks: true, headers: true, converters: csv_converter)
    @csv_data.take(1) # Ensure the headers are read
    @csv_data = CSV.open(data.path, encoding: 'UTF-8', skip_blanks: true, headers: ['#domain'], converters: csv_converter) unless @csv_data.headers&.first == '#domain'
    @csv_data
  end

  def csv_row_count
    return @csv_row_count if defined?(@csv_row_count)

    csv_data.rewind
    @csv_row_count = csv_data.take(ROWS_PROCESSING_LIMIT + 2).count
  end

  def validate_data
    return if data.nil?

    errors.add(:data, I18n.t('imports.errors.over_rows_processing_limit', count: ROWS_PROCESSING_LIMIT)) if csv_row_count > ROWS_PROCESSING_LIMIT
  rescue CSV::MalformedCSVError => e
    errors.add(:data, I18n.t('imports.errors.invalid_csv_file', error: e.message))
  end
end
