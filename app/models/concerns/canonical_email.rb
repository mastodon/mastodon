# frozen_string_literal: true

module CanonicalEmail
  extend ActiveSupport::Concern

  included do
    normalizes :email, with: ->(value) { canonicalize_email(value) }
  end

  class_methods do
    def canonicalize_email(email)
      email
        .downcase
        .split('@', 2)
        .then { |local, domain| [canonical_username(local), domain] }
        .join('@')
    end

    def canonical_username(username)
      username
        .to_s
        .delete('.')
        .split('+', 2)
        .first
    end
  end
end
