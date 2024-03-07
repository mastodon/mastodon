# frozen_string_literal: true

class SignatureParser
  class ParsingError < StandardError; end

  # The syntax of this header is defined in:
  # https://datatracker.ietf.org/doc/html/draft-cavage-http-signatures-12#section-4
  # See https://datatracker.ietf.org/doc/html/rfc7235#appendix-C
  # and https://datatracker.ietf.org/doc/html/rfc7230#section-3.2.6

  # In addition, ignore a `Signature ` string prefix that was added by old versions
  # of `node-http-signatures`

  TOKEN_RE = /[0-9a-zA-Z!#$%&'*+.^_`|~-]+/
  # qdtext and quoted_pair are not exactly according to spec but meh
  QUOTED_STRING_RE = /"([^\\"]|(\\.))*"/
  PARAM_RE = /(?<key>#{TOKEN_RE})\s*=\s*((?<value>#{TOKEN_RE})|(?<quoted_value>#{QUOTED_STRING_RE}))/

  def self.parse(raw_signature)
    # Old versions of node-http-signature add an incorrect "Signature " prefix to the header
    raw_signature = raw_signature.delete_prefix('Signature ')

    params = {}
    scanner = StringScanner.new(raw_signature)

    # Use `skip` instead of `scan` as we only care about the subgroups
    while scanner.skip(PARAM_RE)
      # This is not actually correct with regards to quoted pairs, but it's consistent
      # with our previous implementation, and good enough in practice.
      params[scanner[:key]] = scanner[:value] || scanner[:quoted_value][1...-1]

      scanner.skip(/\s*/)
      return params if scanner.eos?

      raise ParsingError unless scanner.skip(/\s*,\s*/)
    end

    raise ParsingError
  end
end
