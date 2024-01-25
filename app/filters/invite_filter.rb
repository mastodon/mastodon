# frozen_string_literal: true

class InviteFilter < BaseFilter
  KEYS = %i(
    available
    expired
  ).freeze

  private

  def default_filter_scope
    Invite.order(created_at: :desc)
  end

  def scope_for(key, _value)
    case key
    when :available
      Invite.available
    when :expired
      Invite.expired
    else
      raise Mastodon::InvalidParameterError, "Unknown filter: #{key}"
    end
  end
end
