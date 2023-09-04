# frozen_string_literal: true

require 'csv'

class ImportValidator < ActiveModel::Validator
  KNOWN_HEADERS = [
    'Account address',
    '#domain',
    '#uri',
  ].freeze

  def validate(import)
    return if import.type.blank? || import.data.blank?

    # We parse because newlines could be part of individual rows. This
    # runs on create so we should be reading the local file here before
    # it is uploaded to object storage or moved anywhere...
    csv_data = CSV.parse(import.data.queued_for_write[:original].read)

    row_count  = csv_data.size
    row_count -= 1 if KNOWN_HEADERS.include?(csv_data.first&.first)

    import.errors.add(:data, I18n.t('imports.errors.over_rows_processing_limit', count: ImportService::ROWS_PROCESSING_LIMIT)) if row_count > ImportService::ROWS_PROCESSING_LIMIT

    case import.type
    when 'following'
      validate_following_import(import, row_count)
    end
  rescue CSV::MalformedCSVError
    import.errors.add(:data, :malformed)
  end

  private

  def validate_following_import(import, row_count)
    base_limit = FollowLimitValidator.limit_for_account(import.account)

    limit = begin
      if import.overwrite?
        base_limit
      else
        base_limit - import.account.following_count
      end
    end

    import.errors.add(:data, I18n.t('users.follow_limit_reached', limit: base_limit)) if row_count > limit
  end
end
