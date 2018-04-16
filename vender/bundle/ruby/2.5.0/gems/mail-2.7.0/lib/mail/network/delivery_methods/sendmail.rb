# frozen_string_literal: true
require 'mail/check_delivery_params'

module Mail
  # A delivery method implementation which sends via sendmail.
  #
  # To use this, first find out where the sendmail binary is on your computer,
  # if you are on a mac or unix box, it is usually in /usr/sbin/sendmail, this will
  # be your sendmail location.
  #
  #   Mail.defaults do
  #     delivery_method :sendmail
  #   end
  #
  # Or if your sendmail binary is not at '/usr/sbin/sendmail'
  #
  #   Mail.defaults do
  #     delivery_method :sendmail, :location => '/absolute/path/to/your/sendmail'
  #   end
  #
  # Then just deliver the email as normal:
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
  class Sendmail
    DEFAULTS = {
      :location   => '/usr/sbin/sendmail',
      :arguments  => '-i'
    }

    attr_accessor :settings

    def initialize(values)
      self.settings = self.class::DEFAULTS.merge(values)
    end

    def deliver!(mail)
      smtp_from, smtp_to, message = Mail::CheckDeliveryParams.check(mail)

      from = "-f #{self.class.shellquote(smtp_from)}" if smtp_from
      to = smtp_to.map { |_to| self.class.shellquote(_to) }.join(' ')

      arguments = "#{settings[:arguments]} #{from} --"
      self.class.call(settings[:location], arguments, to, message)
    end

    def self.call(path, arguments, destinations, encoded_message)
      popen "#{path} #{arguments} #{destinations}" do |io|
        io.puts ::Mail::Utilities.binary_unsafe_to_lf(encoded_message)
        io.flush
      end
    end

    if RUBY_VERSION < '1.9.0'
      def self.popen(command, &block)
        IO.popen "#{command} 2>&1", 'w+', &block
      end
    else
      def self.popen(command, &block)
        IO.popen command, 'w+', :err => :out, &block
      end
    end

    # The following is an adaptation of ruby 1.9.2's shellwords.rb file,
    # with the following modifications:
    #
    # - Wraps in double quotes
    # - Allows '+' to accept email addresses with them
    # - Allows '~' as it is not unescaped in double quotes
    def self.shellquote(address)
      # Process as a single byte sequence because not all shell
      # implementations are multibyte aware.
      #
      # A LF cannot be escaped with a backslash because a backslash + LF
      # combo is regarded as line continuation and simply ignored. Strip it.
      escaped = address.gsub(/([^A-Za-z0-9_\s\+\-.,:\/@~])/n, "\\\\\\1").gsub("\n", '')
      %("#{escaped}")
    end
  end
end
