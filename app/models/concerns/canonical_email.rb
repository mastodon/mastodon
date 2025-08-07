# frozen_string_literal: true

module CanonicalEmail
  extend ActiveSupport::Concern

  included do
    normalizes :email, with: ->(value) { canonicalize_email(value) }
  end

  class_methods do
    def canonicalize_email(email)
      Mail::Address
        .new(email)
        .then { |address| [canonical_username(address.local), address.domain] }
        .join('@')
        .downcase
    rescue Mail::Field::FieldError
      email
    end

    def canonical_username(username)
      username.to_s.delete('.').split('+', 2).first
    end
  end
end
