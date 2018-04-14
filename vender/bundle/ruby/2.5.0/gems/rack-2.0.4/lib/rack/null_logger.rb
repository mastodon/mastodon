module Rack
  class NullLogger
    def initialize(app)
      @app = app
    end

    def call(env)
      env[RACK_LOGGER] = self
      @app.call(env)
    end

    def info(progname = nil, &block); end
    def debug(progname = nil, &block); end
    def warn(progname = nil, &block); end
    def error(progname = nil, &block); end
    def fatal(progname = nil, &block); end
    def unknown(progname = nil, &block); end
    def info? ;  end
    def debug? ; end
    def warn? ;  end
    def error? ; end
    def fatal? ; end
    def level ; end
    def progname ; end
    def datetime_format ; end
    def formatter ; end
    def sev_threshold ; end
    def level=(level); end
    def progname=(progname); end
    def datetime_format=(datetime_format); end
    def formatter=(formatter); end
    def sev_threshold=(sev_threshold); end
    def close ; end
    def add(severity, message = nil, progname = nil, &block); end
    def <<(msg); end
  end
end
