# frozen_string_literal: true

class Admin::StatusFilter
  KEYS = %i(
    media
    report_id
  ).freeze

  IGNORED_PARAMS = %w(page report_id).freeze

  attr_reader :params

  def initialize(account, params)
    @account = account
    @params  = params
  end

  def results
    scope = @account.statuses.distributable_visibility

    params.each do |key, value|
      next if IGNORED_PARAMS.include?(key.to_s)

      scope.merge!(scope_for(key, value.to_s.strip)) if value.present?
    end

    scope
  end

  private

  def scope_for(key, _value)
    case key.to_s
    when 'media'
      Status.joins(:media_attachments).merge(@account.media_attachments).group(:id).reorder('statuses.id desc')
    else
      raise Mastodon::InvalidParameterError, "Unknown filter: #{key}"
    end
  end
end
