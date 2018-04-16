module Puma
  # Rack::CommonLogger forwards every request to the given +app+, and
  # logs a line in the
  # {Apache common log format}[http://httpd.apache.org/docs/1.3/logs.html#common]
  # to the +logger+.
  #
  # If +logger+ is nil, CommonLogger will fall back +rack.errors+, which is
  # an instance of Rack::NullLogger.
  #
  # +logger+ can be any class, including the standard library Logger, and is
  # expected to have either +write+ or +<<+ method, which accepts the CommonLogger::FORMAT.
  # According to the SPEC, the error stream must also respond to +puts+
  # (which takes a single argument that responds to +to_s+), and +flush+
  # (which is called without arguments in order to make the error appear for
  # sure)
  class CommonLogger
    # Common Log Format: http://httpd.apache.org/docs/1.3/logs.html#common
    #
    #   lilith.local - - [07/Aug/2006 23:58:02 -0400] "GET / HTTP/1.1" 500 -
    #
    #   %{%s - %s [%s] "%s %s%s %s" %d %s\n} %
    FORMAT = %{%s - %s [%s] "%s %s%s %s" %d %s %0.4f\n}

    HIJACK_FORMAT = %{%s - %s [%s] "%s %s%s %s" HIJACKED -1 %0.4f\n}

    CONTENT_LENGTH = 'Content-Length'.freeze
    PATH_INFO      = 'PATH_INFO'.freeze
    QUERY_STRING   = 'QUERY_STRING'.freeze
    REQUEST_METHOD = 'REQUEST_METHOD'.freeze

    def initialize(app, logger=nil)
      @app = app
      @logger = logger
    end

    def call(env)
      began_at = Time.now
      status, header, body = @app.call(env)
      header = Util::HeaderHash.new(header)

      # If we've been hijacked, then output a special line
      if env['rack.hijack_io']
        log_hijacking(env, 'HIJACK', header, began_at)
      else
        ary = env['rack.after_reply']
        ary << lambda { log(env, status, header, began_at) }
      end

      [status, header, body]
    end

    private

    def log_hijacking(env, status, header, began_at)
      now = Time.now

      msg = HIJACK_FORMAT % [
        env['HTTP_X_FORWARDED_FOR'] || env["REMOTE_ADDR"] || "-",
        env["REMOTE_USER"] || "-",
        now.strftime("%d/%b/%Y %H:%M:%S"),
        env[REQUEST_METHOD],
        env[PATH_INFO],
        env[QUERY_STRING].empty? ? "" : "?#{env[QUERY_STRING]}",
        env["HTTP_VERSION"],
        now - began_at ]

      write(msg)
    end

    def log(env, status, header, began_at)
      now = Time.now
      length = extract_content_length(header)

      msg = FORMAT % [
        env['HTTP_X_FORWARDED_FOR'] || env["REMOTE_ADDR"] || "-",
        env["REMOTE_USER"] || "-",
        now.strftime("%d/%b/%Y:%H:%M:%S %z"),
        env[REQUEST_METHOD],
        env[PATH_INFO],
        env[QUERY_STRING].empty? ? "" : "?#{env[QUERY_STRING]}",
        env["HTTP_VERSION"],
        status.to_s[0..3],
        length,
        now - began_at ]

      write(msg)
    end

    def write(msg)
      logger = @logger || env['rack.errors']

      # Standard library logger doesn't support write but it supports << which actually
      # calls to write on the log device without formatting
      if logger.respond_to?(:write)
        logger.write(msg)
      else
        logger << msg
      end
    end

    def extract_content_length(headers)
      value = headers[CONTENT_LENGTH] or return '-'
      value.to_s == '0' ? '-' : value
    end
  end
end
