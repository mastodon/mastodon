# :markup: markdown

# An abstract superclass for all saver classes.
class HTTP::CookieJar::AbstractSaver
  class << self
    @@class_map = {}

    # Gets an implementation class by the name, optionally trying to
    # load "http/cookie_jar/*_saver" if not found.  If loading fails,
    # IndexError is raised.
    def implementation(symbol)
      @@class_map.fetch(symbol)
    rescue IndexError
      begin
        require 'http/cookie_jar/%s_saver' % symbol
        @@class_map.fetch(symbol)
      rescue LoadError, IndexError
        raise IndexError, 'cookie saver unavailable: %s' % symbol.inspect
      end
    end

    def inherited(subclass) # :nodoc:
      @@class_map[class_to_symbol(subclass)] = subclass
    end

    def class_to_symbol(klass) # :nodoc:
      klass.name[/[^:]+?(?=Saver$|$)/].downcase.to_sym
    end
  end

  # Defines options and their default values.
  def default_options
    # {}
  end
  private :default_options

  # :call-seq:
  #   new(**options)
  #
  # Called by the constructor of each subclass using super().
  def initialize(options = nil)
    options ||= {}
    @logger  = options[:logger]
    @session = options[:session]
    # Initializes each instance variable of the same name as option
    # keyword.
    default_options.each_pair { |key, default|
      instance_variable_set("@#{key}", options.fetch(key, default))
    }
  end

  # Implements HTTP::CookieJar#save().
  #
  # This is an abstract method that each subclass must override.
  def save(io, jar)
    # self
  end

  # Implements HTTP::CookieJar#load().
  #
  # This is an abstract method that each subclass must override.
  def load(io, jar)
    # self
  end
end
