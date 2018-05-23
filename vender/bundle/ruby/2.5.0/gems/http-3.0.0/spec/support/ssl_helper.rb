# frozen_string_literal: true

require "pathname"

require "certificate_authority"

module SSLHelper
  CERTS_PATH = Pathname.new File.expand_path("../../../tmp/certs", __FILE__)

  class RootCertificate < ::CertificateAuthority::Certificate
    EXTENSIONS = {"keyUsage" => {"usage" => %w[critical keyCertSign]}}.freeze

    def initialize
      super()

      subject.common_name  = "honestachmed.com"
      serial_number.number = 1
      key_material.generate_key

      self.signing_entity = true

      sign!("extensions" => EXTENSIONS)
    end

    def file
      return @file if defined? @file

      CERTS_PATH.mkpath

      cert_file = CERTS_PATH.join("ca.crt")
      cert_file.open("w") { |io| io << to_pem }

      @file = cert_file.to_s
    end
  end

  class ChildCertificate < ::CertificateAuthority::Certificate
    def initialize(parent)
      super()

      subject.common_name  = "127.0.0.1"
      serial_number.number = 1

      key_material.generate_key

      self.parent = parent

      sign!
    end

    def cert
      OpenSSL::X509::Certificate.new to_pem
    end

    def key
      OpenSSL::PKey::RSA.new key_material.private_key.to_pem
    end
  end

  class << self
    def server_context
      context = OpenSSL::SSL::SSLContext.new

      context.verify_mode = OpenSSL::SSL::VERIFY_PEER
      context.key         = server_cert.key
      context.cert        = server_cert.cert
      context.ca_file     = ca.file

      context
    end

    def client_context
      context = OpenSSL::SSL::SSLContext.new

      context.options     = OpenSSL::SSL::SSLContext::DEFAULT_PARAMS[:options]
      context.verify_mode = OpenSSL::SSL::VERIFY_PEER
      context.key         = client_cert.key
      context.cert        = client_cert.cert
      context.ca_file     = ca.file

      context
    end

    def client_params
      {
        :key => client_cert.key,
        :cert => client_cert.cert,
        :ca_file => ca.file
      }
    end

    %w[server client].each do |side|
      class_eval <<-RUBY, __FILE__, __LINE__
        def #{side}_cert
          @#{side}_cert ||= ChildCertificate.new ca
        end
      RUBY
    end

    def ca
      @ca ||= RootCertificate.new
    end
  end
end
