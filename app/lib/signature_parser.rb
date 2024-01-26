# frozen_string_literal: true

class SignatureParser
  class ParsingError < StandardError; end

  # The syntax of this header is defined in:
  # https://datatracker.ietf.org/doc/html/draft-cavage-http-signatures-12#section-4
  # See https://datatracker.ietf.org/doc/html/rfc7235#appendix-C
  # and https://datatracker.ietf.org/doc/html/rfc7230#section-3.2.6

  # In addition, ignore a `Signature ` string prefix that was added by old versions
  # of `node-http-signatures`

  class SignatureParamsParser < Parslet::Parser
    rule(:token)         { match("[0-9a-zA-Z!#$%&'*+.^_`|~-]").repeat(1).as(:token) }
    rule(:quoted_string) { str('"') >> (qdtext | quoted_pair).repeat.as(:quoted_string) >> str('"') }
    # qdtext and quoted_pair are not exactly according to spec but meh
    rule(:qdtext)        { match('[^\\\\"]') }
    rule(:quoted_pair)   { str('\\') >> any }
    rule(:bws)           { match('\s').repeat }
    rule(:param)         { (token.as(:key) >> bws >> str('=') >> bws >> (token | quoted_string).as(:value)).as(:param) }
    rule(:comma)         { bws >> str(',') >> bws }
    # Old versions of node-http-signature add an incorrect "Signature " prefix to the header
    rule(:buggy_prefix)  { str('Signature ') }
    rule(:params)        { buggy_prefix.maybe >> (param >> (comma >> param).repeat).as(:params) }
    root(:params)
  end

  class SignatureParamsTransformer < Parslet::Transform
    rule(params: subtree(:param)) do
      (param.is_a?(Array) ? param : [param]).each_with_object({}) { |(key, value), hash| hash[key] = value }
    end

    rule(param: { key: simple(:key), value: simple(:val) }) do
      [key, val]
    end

    rule(quoted_string: simple(:string)) do
      string.to_s
    end

    rule(token: simple(:string)) do
      string.to_s
    end
  end

  def self.parse(raw_signature)
    tree = SignatureParamsParser.new.parse(raw_signature)
    SignatureParamsTransformer.new.apply(tree)
  rescue Parslet::ParseFailed
    raise ParsingError
  end
end
