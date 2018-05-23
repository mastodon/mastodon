require 'forwardable'

module Faraday
  class Response::Logger < Response::Middleware
    extend Forwardable

    DEFAULT_OPTIONS = { :headers => true, :bodies => false }

    def initialize(app, logger = nil, options = {})
      super(app)
      @logger = logger || begin
        require 'logger'
        ::Logger.new(STDOUT)
      end
      @filter = []
      @options = DEFAULT_OPTIONS.merge(options)
      yield self if block_given?
    end

    def_delegators :@logger, :debug, :info, :warn, :error, :fatal

    def call(env)
      info "#{env.method} #{apply_filters(env.url.to_s)}"
      debug('request') { apply_filters( dump_headers env.request_headers ) } if log_headers?(:request)
      debug('request') { apply_filters( dump_body(env[:body]) ) } if env[:body] && log_body?(:request)
      super
    end

    def on_complete(env)
      info('Status') { env.status.to_s }
      debug('response') { apply_filters( dump_headers env.response_headers ) } if log_headers?(:response)
      debug('response') { apply_filters( dump_body env[:body] ) } if env[:body] && log_body?(:response)
    end

    def filter(filter_word, filter_replacement)
      @filter.push([ filter_word, filter_replacement ])
    end

    private

    def dump_headers(headers)
      headers.map { |k, v| "#{k}: #{v.inspect}" }.join("\n")
    end

    def dump_body(body)
      if body.respond_to?(:to_str)
        body.to_str
      else
        pretty_inspect(body)
      end
    end

    def pretty_inspect(body)
      require 'pp' unless body.respond_to?(:pretty_inspect)
      body.pretty_inspect
    end

    def log_headers?(type)
      case @options[:headers]
      when Hash then @options[:headers][type]
      else @options[:headers]
      end
    end

    def log_body?(type)
      case @options[:bodies]
      when Hash then @options[:bodies][type]
      else @options[:bodies]
      end
    end

    def apply_filters(output)
      @filter.each do |pattern, replacement|
        output = output.to_s.gsub(pattern, replacement)
      end
      output
    end

  end
end
