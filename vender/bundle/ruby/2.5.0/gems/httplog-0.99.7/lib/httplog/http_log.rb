require "net/http"
require "logger"
require "benchmark"
require "colorize"
require "rack"

module HttpLog
  LOG_PREFIX = "[httplog] ".freeze

  class << self

    attr_accessor :configuration

    def configuration
      @configuration ||= Configuration.new
    end
    alias_method :config, :configuration
    alias_method :options, :configuration # TODO: remove with 1.0.0

    def reset!
      @configuration = nil
    end

    def configure
      yield(configuration)
    end

    def url_approved?(url)
      return false if config.url_blacklist_pattern && url.to_s.match(config.url_blacklist_pattern)
      url.to_s.match(config.url_whitelist_pattern)
    end

    def log(msg)
      return unless config.enabled
      config.logger.log(config.severity, colorize(prefix + msg))
    end

    def log_connection(host, port = nil)
      return if config.compact_log || !config.log_connect
      log("Connecting: #{[host, port].compact.join(":")}")
    end

    def log_request(method, uri)
      return if config.compact_log || !config.log_request
      log("Sending: #{method.to_s.upcase} #{uri}")
    end

    def log_headers(headers = {})
      return if config.compact_log || !config.log_headers
      headers.each do |key,value|
        log("Header: #{key}: #{value}")
      end
    end

    def log_status(status)
      return if config.compact_log || !config.log_status
      status = Rack::Utils.status_code(status) unless status == /\d{3}/
      log("Status: #{status}")
    end

    def log_benchmark(seconds)
      return if config.compact_log || !config.log_benchmark
      log("Benchmark: #{seconds.to_f.round(6)} seconds")
    end

    def log_body(body, encoding = nil, content_type=nil)
      return if config.compact_log || !config.log_response

      unless text_based?(content_type)
        log("Response: (not showing binary data)")
        return
      end

      if body.is_a?(Net::ReadAdapter)
        # open-uri wraps the response in a Net::ReadAdapter that defers reading
        # the content, so the reponse body is not available here.
        log("Response: (not available yet)")
        return
      end

      if encoding =~ /gzip/ && body && !body.empty?
        sio = StringIO.new( body.to_s )
        gz = Zlib::GzipReader.new( sio )
        body = gz.read
      end

      data = utf_encoded(body.to_s, content_type)

      if config.prefix_response_lines
        log("Response:")
        log_data_lines(data)
      else
        log("Response:\n#{data}")
      end

    end

    def log_data(data)
      return if config.compact_log || !config.log_data
      data = utf_encoded(data.to_s.dup)

      if config.prefix_data_lines
        log("Data:")
        log_data_lines(data)
      else
        log("Data: #{data}")
      end
    end

    def log_compact(method, uri, status, seconds)
      return unless config.compact_log
      status = Rack::Utils.status_code(status) unless status == /\d{3}/
      log("#{method.to_s.upcase} #{uri} completed with status code #{status} in #{seconds} seconds")
    end

    def colorize(msg)
      return msg unless config.color
      msg.send(:colorize, config.color)
    end

    private

    def utf_encoded(data, content_type=nil)
      charset = content_type.to_s.scan(/; charset=(\S+)/).flatten.first || 'UTF-8'
      data.force_encoding(charset) rescue data.force_encoding('UTF-8')
      data.encode('UTF-8', :invalid => :replace, :undef => :replace)
    end

    def text_based?(content_type)
      # This is a very naive way of determining if the content type is text-based; but
      # it will allow application/json and the like without having to resort to more
      # heavy-handed checks.
      content_type =~ /^text/ ||
      content_type =~ /^application/ && content_type != 'application/octet-stream'
    end

    def log_data_lines(data)
      data.each_line.with_index do |line, row|
        if config.prefix_line_numbers
          log("#{row + 1}: #{line.chomp}")
        else
          log(line.strip)
        end
      end
    end

    def prefix
      if config.prefix.respond_to?(:call)
        config.prefix.call
      else
        config.prefix.to_s
      end
    end

  end
end
