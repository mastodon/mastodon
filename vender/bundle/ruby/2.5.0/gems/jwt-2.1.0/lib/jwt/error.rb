# frozen_string_literal: true

module JWT
  class EncodeError < StandardError; end
  class DecodeError < StandardError; end
  class VerificationError < DecodeError; end
  class ExpiredSignature < DecodeError; end
  class IncorrectAlgorithm < DecodeError; end
  class ImmatureSignature < DecodeError; end
  class InvalidIssuerError < DecodeError; end
  class InvalidIatError < DecodeError; end
  class InvalidAudError < DecodeError; end
  class InvalidSubError < DecodeError; end
  class InvalidJtiError < DecodeError; end
  class InvalidPayload < DecodeError; end
end
