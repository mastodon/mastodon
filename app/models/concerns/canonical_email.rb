# frozen_string_literal: true

module CanonicalEmail
  extend ActiveSupport::Concern

  class_methods do
    def email_to_canonical_email_hash(value)
      Digest::SHA2
        .new(256)
        .hexdigest(
          email_to_canonical_email(value)
        )
    end

    private

    def email_to_canonical_email(value)
      username, domain = value.downcase.split('@', 2)
      username, = username.delete('.').split('+', 2)

      "#{username}@#{domain}"
    end
  end
end
