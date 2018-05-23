# frozen_string_literal: true
module Mail
  module CheckDeliveryParams #:nodoc:
    class << self
      def check(mail)
        [ check_from(mail.smtp_envelope_from),
          check_to(mail.smtp_envelope_to),
          check_message(mail) ]
      end

      def check_from(addr)
        if Utilities.blank?(addr)
          raise ArgumentError, "SMTP From address may not be blank: #{addr.inspect}"
        end

        check_addr 'From', addr
      end

      def check_to(addrs)
        if Utilities.blank?(addrs)
          raise ArgumentError, "SMTP To address may not be blank: #{addrs.inspect}"
        end

        Array(addrs).map do |addr|
          check_addr 'To', addr
        end
      end

      def check_addr(addr_name, addr)
        validate_smtp_addr addr do |error_message|
          raise ArgumentError, "SMTP #{addr_name} address #{error_message}: #{addr.inspect}"
        end
      end

      def validate_smtp_addr(addr)
        if addr
          if addr.bytesize > 2048
            yield 'may not exceed 2kB'
          end

          if /[\r\n]/ =~ addr
            yield 'may not contain CR or LF line breaks'
          end
        end

        addr
      end

      def check_message(message)
        message = message.encoded if message.respond_to?(:encoded)

        if Utilities.blank?(message)
          raise ArgumentError, 'An encoded message is required to send an email'
        end

        message
      end
    end
  end
end
