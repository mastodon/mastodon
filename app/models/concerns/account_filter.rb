# frozen_string_literal: true

module AccountFilter
  extend ActiveSupport::Concern

  included do
    scope(:filter, ->(params) do
      params.to_enum.inject(alphabetic) do |scope, pair|
        key = pair[0]
        value = pair[1]

        case key.to_s
        when 'local'
          scope.local
        when 'remote'
          scope.remote
        when 'by_domain'
          scope.where(domain: value)
        when 'silenced'
          scope.silenced
        when 'recent'
          scope.recent
        when 'suspended'
          scope.suspended
        when 'username'
          scope.matches_username(value)
        when 'display_name'
          scope.matches_display_name(value)
        when 'email'
          scope.joins(:user).merge User.matches_email(value)
        when 'ip'
          scope.joins(:user).merge User.with_recent_ip_address(value)
        else
          raise "Unknown filter: #{key}"
        end
      end
    end)
  end
end
