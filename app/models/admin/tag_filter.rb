# frozen_string_literal: true

class Admin::TagFilter
  KEYS = %i(
    status
    name
    order
  ).freeze

  attr_reader :params

  def initialize(params)
    @params = params.to_h.symbolize_keys
  end

  def results
    scope = Tag.reorder(nil)

    params.each do |key, value|
      next if key.to_s == 'page'

      scope.merge!(scope_for(key, value)) if value.present?
    end

    scope
  end

  private

  def scope_for(key, value)
    case key.to_s
    when 'status'
      status_scope(value)
    when 'name'
      Tag.search_for(value.to_s.strip, params[:limit], params[:offset], include_unlistable: true)
    when 'order'
      order_scope(value)
    else
      raise Mastodon::InvalidParameterError, "Unknown filter: #{key}"
    end
  end

  def status_scope(value)
    case value.to_s
    when 'reviewed'
      Tag.reviewed
    when 'pending_review'
      Tag.pending_review
    when 'unreviewed'
      Tag.unreviewed
    when 'trendable'
      Tag.trendable
    when 'not_trendable'
      Tag.not_trendable
    when 'usable'
      Tag.usable
    else
      raise Mastodon::InvalidParameterError, "Unknown status: #{value}"
    end
  end

  def order_scope(value)
    case value.to_s
    when 'newest'
      Tag.order(created_at: :desc)
    when 'oldest'
      Tag.order(created_at: :asc)
    when 'pending_review'
      Tag.order(requested_review_at: :desc)
    else
      raise Mastodon::InvalidParameterError, "Unknown order: #{value}"
    end
  end
end
