module OStatus2
  class Salmon
    include OStatus2::MagicKey

    XMLNS = 'http://salmon-protocol.org/ns/magic-env'

    # Create a magical envelope XML document around the original body
    # and sign it with a private key
    # @param [String] body
    # @param [OpenSSL::PKey::RSA] key The private part of the key will be used
    # @return [String] Magical envelope XML
    def pack(body, key)
      signed    = plaintext_signature(body, 'application/atom+xml', 'base64url', 'RSA-SHA256')
      signature = Base64.urlsafe_encode64(key.sign(digest, signed))

      Nokogiri::XML::Builder.new do |xml|
        xml['me'].env({ 'xmlns:me' => XMLNS }) do
          xml['me'].data({ type: 'application/atom+xml' }, Base64.urlsafe_encode64(body))
          xml['me'].encoding('base64url')
          xml['me'].alg('RSA-SHA256')
          xml['me'].sig({ key_id: Base64.urlsafe_encode64(key.public_key.to_s) }, signature)
        end
      end.to_xml
    end

    # Deliver the magical envelope to a Salmon endpoint
    # @param [String] salmon_url Salmon endpoint URL
    # @param [String] envelope Magical envelope
    # @raise [HTTP::Error] Error raised upon delivery failure
    # @raise [OpenSSL::SSL::SSLError] Error raised upon SSL-related failure during delivery
    # @return [HTTP::Response]
    def post(salmon_url, envelope)
      http_client.headers(HTTP::Headers::CONTENT_TYPE => 'application/magic-envelope+xml').post(Addressable::URI.parse(salmon_url), body: envelope)
    end

    # Unpack a magical envelope to get the content inside
    # @param [String] raw_body Magical envelope
    # @raise [OStatus2::BadSalmonError] Error raised if the envelope is malformed
    # @return [String] Content inside the envelope
    def unpack(raw_body)
      body, _, _ = parse(raw_body)
      body
    end

    # Verify the magical envelope's integrity
    # @param [String] raw_body Magical envelope
    # @param [OpenSSL::PKey::RSA] key The public part of the key will be used
    # @return [Boolean]
    def verify(raw_body, key)
      _, plaintext, signature = parse(raw_body)
      key.public_key.verify(digest, signature, plaintext)
    rescue OStatus2::BadSalmonError
      false
    end

    private

    def http_client
      HTTP.timeout(:per_operation, write: 60, connect: 20, read: 60)
    end

    def digest
      OpenSSL::Digest::SHA256.new
    end

    def parse(raw_body)
      xml = Nokogiri::XML(raw_body)

      raise OStatus2::BadSalmonError if xml.at_xpath('//me:data', me: XMLNS).nil? || xml.at_xpath('//me:data', me: XMLNS).attribute('type').nil? || xml.at_xpath('//me:sig', me: XMLNS).nil? || xml.at_xpath('//me:encoding', me: XMLNS).nil? || xml.at_xpath('//me:alg', me: XMLNS).nil?

      data      = xml.at_xpath('//me:data', me: XMLNS)
      type      = data.attribute('type').value
      body      = decode_base64(data.content.gsub(/\s+/, ''))
      sig       = xml.at_xpath('//me:sig', me: XMLNS)
      signature = decode_base64(sig.content.gsub(/\s+/, ''))
      encoding  = xml.at_xpath('//me:encoding', me: XMLNS).content
      alg       = xml.at_xpath('//me:alg', me: XMLNS).content
      plaintext = plaintext_signature(body, type, encoding, alg)

      [body, plaintext, signature]
    end

    def plaintext_signature(data, type, encoding, alg)
      [data, type, encoding, alg].map { |i| Base64.urlsafe_encode64(i) }.join('.')
    end
  end
end
