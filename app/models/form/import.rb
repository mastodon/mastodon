# frozen_string_literal: true

require 'csv'

# A non-ActiveRecord helper class for CSV uploads.
# Handles saving contents to database.
class Form::Import
  include ActiveModel::Model

  MODES = %i(merge overwrite).freeze

  FILE_SIZE_LIMIT       = 20.megabytes
  ROWS_PROCESSING_LIMIT = 20_000

  EXPECTED_HEADERS_BY_TYPE = {
    following: ['Account address', 'Show boosts', 'Notify on new posts', 'Languages'],
    blocking: ['Account address'],
    muting: ['Account address', 'Hide notifications'],
    domain_blocking: ['#domain'],
    bookmarks: ['#uri'],
    lists: ['List name', 'Account address'],
  }.freeze

  KNOWN_FIRST_HEADERS = EXPECTED_HEADERS_BY_TYPE.values.map(&:first).uniq.freeze

  ATTRIBUTE_BY_HEADER = {
    'Account address' => 'acct',
    'Show boosts' => 'show_reblogs',
    'Notify on new posts' => 'notify',
    'Languages' => 'languages',
    'Hide notifications' => 'hide_notifications',
    '#domain' => 'domain',
    '#uri' => 'uri',
    'List name' => 'list_name',
  }.freeze

  class EmptyFileError < StandardError; end

  attr_accessor :current_account, :data, :type, :overwrite, :bulk_import

  validates :type, presence: true
  validates :data, presence: true
  validate :validate_data

  def guessed_type
    if csv_headers_match?('Hide notifications') || file_name_matches?('mutes') || file_name_matches?('muted_accounts')
      :muting
    elsif csv_headers_match?('Show boosts') || csv_headers_match?('Notify on new posts') || csv_headers_match?('Languages') || file_name_matches?('follows') || file_name_matches?('following_accounts')
      :following
    elsif file_name_matches?('blocks') || file_name_matches?('blocked_accounts')
      :blocking
    elsif file_name_matches?('domain_blocks') || file_name_matches?('blocked_domains')
      :domain_blocking
    elsif file_name_matches?('bookmarks')
      :bookmarks
    elsif file_name_matches?('lists')
      :lists
    end
  end

  # Whether the uploaded CSV file seems to correspond to a different import type than the one selected
  def likely_mismatched?
    guessed_type.present? && guessed_type != type.to_sym
  end

  def save
    return false unless valid?

    ApplicationRecord.transaction do
      now = Time.now.utc
      @bulk_import = current_account.bulk_imports.create(type: type, overwrite: overwrite || false, state: :unconfirmed, original_filename: data.original_filename, likely_mismatched: likely_mismatched?)
      nb_items = BulkImportRow.insert_all(parsed_rows.map { |row| { bulk_import_id: bulk_import.id, data: row, created_at: now, updated_at: now } }).length
      @bulk_import.update(total_items: nb_items)
    end
  end

  def mode
    overwrite ? :overwrite : :merge
  end

  def mode=(str)
    self.overwrite = str.to_sym == :overwrite
  end

  private

  def file_name_matches?(string)
    data.original_filename&.start_with?(string)
  end

  def csv_headers_match?(string)
    csv_data.headers.include?(string)
  end

  def default_csv_headers
    case type.to_sym
    when :following, :blocking, :muting
      ['Account address']
    when :domain_blocking
      ['#domain']
    when :bookmarks
      ['#uri']
    when :lists
      ['List name', 'Account address']
    end
  end

  def csv_data
    return @csv_data if defined?(@csv_data)

    csv_converter = lambda do |field, field_info|
      case field_info.header
      when 'Show boosts', 'Notify on new posts', 'Hide notifications'
        ActiveModel::Type::Boolean.new.cast(field&.downcase)
      when 'Languages'
        field&.split(',')&.map(&:strip)&.presence
      when 'Account address'
        field.strip.gsub(/\A@/, '')
      when '#domain'
        field&.strip&.downcase
      when '#uri', 'List name'
        field.strip
      else
        field
      end
    end

    @csv_data = CSV.open(data.path, encoding: 'UTF-8', skip_blanks: true, headers: true, converters: csv_converter)
    @csv_data.take(1) # Ensure the headers are read
    raise EmptyFileError if @csv_data.headers == true

    @csv_data = CSV.open(data.path, encoding: 'UTF-8', skip_blanks: true, headers: default_csv_headers, converters: csv_converter) unless KNOWN_FIRST_HEADERS.include?(@csv_data.headers&.first)
    @csv_data
  end

  def csv_row_count
    return @csv_row_count if defined?(@csv_row_count)

    csv_data.rewind
    @csv_row_count = csv_data.take(ROWS_PROCESSING_LIMIT + 2).count
  end

  def parsed_rows
    csv_data.rewind

    expected_headers = EXPECTED_HEADERS_BY_TYPE[type.to_sym]

    csv_data.take(ROWS_PROCESSING_LIMIT + 1).map do |row|
      row.to_h.slice(*expected_headers).transform_keys { |key| ATTRIBUTE_BY_HEADER[key] }
    end
  end

  def validate_data
    return if data.nil?
    return errors.add(:data, I18n.t('imports.errors.too_large')) if data.size > FILE_SIZE_LIMIT
    return errors.add(:data, I18n.t('imports.errors.incompatible_type')) unless default_csv_headers.all? { |header| csv_data.headers.include?(header) }

    errors.add(:data, I18n.t('imports.errors.over_rows_processing_limit', count: ROWS_PROCESSING_LIMIT)) if csv_row_count > ROWS_PROCESSING_LIMIT

    if type.to_sym == :following
      base_limit = FollowLimitValidator.limit_for_account(current_account)
      limit = base_limit
      limit -= current_account.following_count unless overwrite
      errors.add(:data, I18n.t('users.follow_limit_reached', limit: base_limit)) if csv_row_count > limit
    end
  rescue CSV::MalformedCSVError => e
    errors.add(:data, I18n.t('imports.errors.invalid_csv_file', error: e.message))
  rescue EmptyFileError
    errors.add(:data, I18n.t('imports.errors.empty'))
  end
end
