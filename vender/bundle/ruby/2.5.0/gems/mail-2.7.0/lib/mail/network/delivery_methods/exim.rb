# frozen_string_literal: true
module Mail

  # A delivery method implementation which sends via exim.
  #
  # To use this, first find out where the exim binary is on your computer,
  # if you are on a mac or unix box, it is usually in /usr/sbin/exim, this will
  # be your exim location.
  #
  #   Mail.defaults do
  #     delivery_method :exim
  #   end
  #
  # Or if your exim binary is not at '/usr/sbin/exim'
  #
  #   Mail.defaults do
  #     delivery_method :exim, :location => '/absolute/path/to/your/exim'
  #   end
  #
  # Then just deliver the email as normal:
  #
  #   Mail.deliver do
  #     to 'mikel@test.lindsaar.net'
  #     from 'ada@test.lindsaar.net'
  #     subject 'testing exim'
  #     body 'testing exim'
  #   end
  #
  # Or by calling deliver on a Mail message
  #
  #   mail = Mail.new do
  #     to 'mikel@test.lindsaar.net'
  #     from 'ada@test.lindsaar.net'
  #     subject 'testing exim'
  #     body 'testing exim'
  #   end
  #
  #   mail.deliver!
  class Exim < Sendmail
    DEFAULTS = {
      :location   => '/usr/sbin/exim',
      :arguments  => '-i -t'
    }

    def self.call(path, arguments, destinations, encoded_message)
      super path, arguments, nil, encoded_message
    end
  end
end
