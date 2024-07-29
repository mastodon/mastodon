# frozen_string_literal: true

module CanonicalEmail
  extend ActiveSupport::Concern

  class_methods do
    def email_to_canonical_email(str)
      username, domain = str.downcase.split('@', 2)
      username, = username.delete('.').split('+', 2)

      "#{username}@#{domain}"
    end

    def email_to_canonical_email_hash(str)
      Digest::SHA2
        .new(256)
        .hexdigest(
          email_to_canonical_email(str)
        )
    end
  end
end
