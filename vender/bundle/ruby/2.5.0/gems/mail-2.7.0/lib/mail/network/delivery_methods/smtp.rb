# frozen_string_literal: true
require 'mail/check_delivery_params'

module Mail
  # == Sending Email with SMTP
  # 
  # Mail allows you to send emails using SMTP.  This is done by wrapping Net::SMTP in
  # an easy to use manner.
  # 
  # === Sending via SMTP server on Localhost
  # 
  # Sending locally (to a postfix or sendmail server running on localhost) requires
  # no special setup.  Just to Mail.deliver &block or message.deliver! and it will
  # be sent in this method.
  # 
  # === Sending via MobileMe
  # 
  #   Mail.defaults do
  #     delivery_method :smtp, { :address              => "smtp.me.com",
  #                              :port                 => 587,
  #                              :domain               => 'your.host.name',
  #                              :user_name            => '<username>',
  #                              :password             => '<password>',
  #                              :authentication       => 'plain',
  #                              :enable_starttls_auto => true  }
  #   end
  # 
  # === Sending via GMail
  # 
  #   Mail.defaults do
  #     delivery_method :smtp, { :address              => "smtp.gmail.com",
  #                              :port                 => 587,
  #                              :domain               => 'your.host.name',
  #                              :user_name            => '<username>',
  #                              :password             => '<password>',
  #                              :authentication       => 'plain',
  #                              :enable_starttls_auto => true  }
  #   end
  #
  # === Certificate verification
  #
  # When using TLS, some mail servers provide certificates that are self-signed
  # or whose names do not exactly match the hostname given in the address.
  # OpenSSL will reject these by default. The best remedy is to use the correct
  # hostname or update the certificate authorities trusted by your ruby. If
  # that isn't possible, you can control this behavior with
  # an :openssl_verify_mode setting. Its value may be either an OpenSSL
  # verify mode constant (OpenSSL::SSL::VERIFY_NONE, OpenSSL::SSL::VERIFY_PEER),
  # or a string containing the name of an OpenSSL verify mode (none, peer).
  #
  # === Others 
  # 
  # Feel free to send me other examples that were tricky
  # 
  # === Delivering the email
  # 
  # Once you have the settings right, sending the email is done by:
  # 
  #   Mail.deliver do
  #     to 'mikel@test.lindsaar.net'
  #     from 'ada@test.lindsaar.net'
  #     subject 'testing sendmail'
  #     body 'testing sendmail'
  #   end
  # 
  # Or by calling deliver on a Mail message
  # 
  #   mail = Mail.new do
  #     to 'mikel@test.lindsaar.net'
  #     from 'ada@test.lindsaar.net'
  #     subject 'testing sendmail'
  #     body 'testing sendmail'
  #   end
  # 
  #   mail.deliver!
  class SMTP
    attr_accessor :settings

    DEFAULTS = {
      :address              => 'localhost',
      :port                 => 25,
      :domain               => 'localhost.localdomain',
      :user_name            => nil,
      :password             => nil,
      :authentication       => nil,
      :enable_starttls      => nil,
      :enable_starttls_auto => true,
      :openssl_verify_mode  => nil,
      :ssl                  => nil,
      :tls                  => nil,
      :open_timeout         => nil,
      :read_timeout         => nil
    }

    def initialize(values)
      self.settings = DEFAULTS.merge(values)
    end

    def deliver!(mail)
      response = start_smtp_session do |smtp|
        Mail::SMTPConnection.new(:connection => smtp, :return_response => true).deliver!(mail)
      end

      settings[:return_response] ? response : self
    end

    private
      def start_smtp_session(&block)
        build_smtp_session.start(settings[:domain], settings[:user_name], settings[:password], settings[:authentication], &block)
      end

      def build_smtp_session
        Net::SMTP.new(settings[:address], settings[:port]).tap do |smtp|
          if settings[:tls] || settings[:ssl]
            if smtp.respond_to?(:enable_tls)
              smtp.enable_tls(ssl_context)
            end
          elsif settings[:enable_starttls]
            if smtp.respond_to?(:enable_starttls)
              smtp.enable_starttls(ssl_context)
            end
          elsif settings[:enable_starttls_auto]
            if smtp.respond_to?(:enable_starttls_auto)
              smtp.enable_starttls_auto(ssl_context)
            end
          end

          smtp.open_timeout = settings[:open_timeout] if settings[:open_timeout]
          smtp.read_timeout = settings[:read_timeout] if settings[:read_timeout]
        end
      end

      # Allow SSL context to be configured via settings, for Ruby >= 1.9
      # Just returns openssl verify mode for Ruby 1.8.x
      def ssl_context
        openssl_verify_mode = settings[:openssl_verify_mode]

        if openssl_verify_mode.kind_of?(String)
          openssl_verify_mode = OpenSSL::SSL.const_get("VERIFY_#{openssl_verify_mode.upcase}")
        end

        context = Net::SMTP.default_ssl_context
        context.verify_mode = openssl_verify_mode if openssl_verify_mode
        context.ca_path = settings[:ca_path] if settings[:ca_path]
        context.ca_file = settings[:ca_file] if settings[:ca_file]
        context
      end
  end
end
