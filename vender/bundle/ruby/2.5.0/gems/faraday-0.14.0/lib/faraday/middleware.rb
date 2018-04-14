module Faraday
  class Middleware
    extend MiddlewareRegistry

    class << self
      attr_accessor :load_error
      private :load_error=
    end

    self.load_error = nil

    # Executes a block which should try to require and reference dependent libraries
    def self.dependency(lib = nil)
      lib ? require(lib) : yield
    rescue LoadError, NameError => error
      self.load_error = error
    end

    def self.new(*)
      raise "missing dependency for #{self}: #{load_error.message}" unless loaded?
      super
    end

    def self.loaded?
      load_error.nil?
    end

    def self.inherited(subclass)
      super
      subclass.send(:load_error=, self.load_error)
    end

    def initialize(app = nil)
      @app = app
    end
  end
end
