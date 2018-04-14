require 'openssl'
require 'em-http'

module EmHttpSslPatch
  def ssl_verify_peer(cert_string)
    cert = nil
    begin
      cert = OpenSSL::X509::Certificate.new(cert_string)
    rescue OpenSSL::X509::CertificateError
      return false
    end

    @last_seen_cert = cert

    if certificate_store.verify(@last_seen_cert)
      begin
        certificate_store.add_cert(@last_seen_cert)
      rescue OpenSSL::X509::StoreError => e
        raise e unless e.message == 'cert already in hash table'
      end
      true
    else
      raise OpenSSL::SSL::SSLError.new(%(unable to verify the server certificate for "#{host}"))
    end
  end

  def ssl_handshake_completed
    return true unless verify_peer?

    unless OpenSSL::SSL.verify_certificate_identity(@last_seen_cert, host)
      raise OpenSSL::SSL::SSLError.new(%(host "#{host}" does not match the server certificate))
    else
      true
    end
  end

  def verify_peer?
    parent.connopts.tls[:verify_peer]
  end

  def host
    parent.uri.host
  end

  def certificate_store
    @certificate_store ||= begin
      store = OpenSSL::X509::Store.new
      store.set_default_paths
      ca_file = parent.connopts.tls[:cert_chain_file]
      store.add_file(ca_file) if ca_file
      store
    end
  end
end

EventMachine::HttpStubConnection.send(:include, EmHttpSslPatch)
