require 'rotp/arguments'

module ROTP
  class CLI
    attr_reader :filename, :argv

    def initialize(filename, argv)
      @filename = filename
      @argv = argv
    end

    def run
      puts output
    end

    def errors
      if [:time, :hmac].include?(options.mode)
        if options.secret.to_s == ''
          red 'You must also specify a --secret. Try --help for help.'
        elsif options.secret.to_s.chars.any? { |c| ROTP::Base32::CHARS.index(c.downcase) == nil }
          red 'Secret must be in RFC4648 Base32 format - http://en.wikipedia.org/wiki/Base32#RFC_4648_Base32_alphabet'
        end
      elsif options.mode == :hmac && options.counter.to_i < 0
        red 'You must also specify a --counter. Try --help for help.'
      end
    end

    def output
      return options.warnings if options.warnings
      return errors if errors
      return arguments.to_s if options.mode == :help

      if options.mode == :time
        ROTP::TOTP.new(options.secret).now
      elsif options.mode == :hmac
        ROTP::HOTP.new(options.secret).at options.counter

      else
        fail NotImplementedError
      end
    end

    def arguments
      @arguments ||= ROTP::Arguments.new(filename, argv)
    end

    def options
      arguments.options
    end

    def red(string)
      "\033[31m#{string}\033[0m"
    end

  end
end
