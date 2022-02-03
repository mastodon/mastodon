# frozen_string_literal: true

class Admin::StatusFilter
  KEYS = %i(
    media
    id
    report_id
  ).freeze

  attr_reader :params

  def initialize(account, params)
    @account = account
    @params  = params
  end

  def results
    scope = @account.statuses.where(visibility: [:public, :unlisted])

    params.each do |key, value|
      next if %w(page report_id).include?(key.to_s)

      scope.merge!(scope_for(key, value.to_s.strip)) if value.present?
    end

    scope
  end

  private

  def scope_for(key, value)
    case key.to_s
    when 'media'
      Status.joins(:media_attachments).merge(@account.media_attachments.reorder(nil)).group(:id)
    when 'id'
      Status.where(id: value)
    else
      raise "Unknown filter: #{key}"
    end
  end
end
