# frozen_string_literal: true

class InviteFilter < BaseFilter
  KEYS = %i(
    available
    expired
  ).freeze

  def results
    scope = Invite.order(created_at: :desc)

    params.each do |key, value|
      scope.merge!(scope_for(key, value)) if value.present?
    end

    scope
  end

  private

  def scope_for(key, _value)
    case key.to_s
    when 'available'
      Invite.available
    when 'expired'
      Invite.expired
    else
      raise Mastodon::InvalidParameterError, "Unknown filter: #{key}"
    end
  end
end
