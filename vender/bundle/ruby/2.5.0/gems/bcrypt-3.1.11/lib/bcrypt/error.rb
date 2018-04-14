module BCrypt

  class Error < StandardError  # :nodoc:
  end

  module Errors  # :nodoc:

    # The salt parameter provided to bcrypt() is invalid.
    class InvalidSalt < BCrypt::Error; end

    # The hash parameter provided to bcrypt() is invalid.
    class InvalidHash < BCrypt::Error; end

    # The cost parameter provided to bcrypt() is invalid.
    class InvalidCost < BCrypt::Error; end

    # The secret parameter provided to bcrypt() is invalid.
    class InvalidSecret < BCrypt::Error; end

  end

end
