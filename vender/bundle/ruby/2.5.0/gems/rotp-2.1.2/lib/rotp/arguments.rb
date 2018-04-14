require 'optparse'
require 'ostruct'

module ROTP
  class Arguments

    def initialize(filename, arguments)
      @filename = filename
      @arguments = Array(arguments)
    end

    def options
      parse
      options!
    end

    def to_s
      parser.help + "\n"
    end

    private

    attr_reader :arguments, :filename

    def options!
      @options ||= default_options
    end

    def default_options
      OpenStruct.new time: true, counter: 0, mode: :time
    end

    def parse
      return options!.mode = :help if arguments.empty?
      parser.parse arguments

    rescue OptionParser::InvalidOption => exception
      options!.mode = :help
      options!.warnings = red(exception.message +  '. Try --help for help.')
    end

    def parser
      OptionParser.new do |parser|
        parser.banner = ''
        parser.separator green('  Usage: ') + bold("#{filename} [options]")
        parser.separator ''
        parser.separator green '  Examples:   '
        parser.separator '    ' + bold("#{filename} --secret p4ssword") + '                       # Generates a time-based one-time password'
        parser.separator '    ' + bold("#{filename} --hmac --secret p4ssword --counter 42") + '   # Generates a counter-based one-time password'
        parser.separator ''
        parser.separator green '  Options:'

        parser.on('-s', '--secret [SECRET]', 'The shared secret') do |secret|
          options!.secret = secret
        end

        parser.on('-c', '--counter [COUNTER]', 'The counter for counter-based hmac OTP') do |counter|
          options!.counter = counter.to_i
        end

        parser.on('-t', '--time', 'Use time-based OTP according to RFC 6238 (default)') do
          options!.mode = :time
        end

        parser.on('-m', '--hmac', 'Use counter-based OTP according to RFC 4226') do
          options!.mode = :hmac
        end

        parser.on_tail('-h', '--help', 'Show this message') do
          options!.mode = :help
        end
      end
    end

    def bold(string)
      "\033[1m#{string}\033[22m"
    end

    def green(string)
      "\033[32m#{string}\033[0m"
    end

    def red(string)
      "\033[31m#{string}\033[0m"
    end

  end
end

