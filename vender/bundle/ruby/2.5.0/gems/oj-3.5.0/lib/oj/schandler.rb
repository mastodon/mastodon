module Oj
  # A Simple Callback Parser (SCP) for JSON. The Oj::ScHandler class should be
  # subclassed and then used with the Oj.sc_parse() method. The Scp methods will
  # then be called as the file is parsed. The handler does not have to be a
  # subclass of the ScHandler class as long as it responds to the desired
  # methods.
  #
  # @example
  #
  #  require 'oj'
  #
  #  class MyHandler < ::Oj::ScHandler
  #    def hash_start
  #      {}
  #    end
  #
  #    def hash_set(h,k,v)
  #      h[k] = v
  #    end
  #
  #    def array_start
  #      []
  #    end
  #
  #    def array_append(a,v)
  #      a << v
  #    end
  #
  #    def add_value(v)
  #      p v
  #    end
  #
  #    def error(message, line, column)
  #      p "ERROR: #{message}"
  #    end
  #  end
  #
  #  File.open('any.json', 'r') do |f|
  #    Oj.sc_parse(MyHandler.new, f)
  #  end
  #
  # To make the desired methods active while parsing the desired method should
  # be made public in the subclasses. If the methods remain private they will
  # not be called during parsing.
  #
  #    def hash_start(); end
  #    def hash_end(); end
  #    def hash_key(key); end
  #    def hash_set(h, key, value); end
  #    def array_start(); end
  #    def array_end(); end
  #    def array_append(a, value); end
  #    def add_value(value); end
  #
  # As certain elements of a JSON document are reached during parsing the
  # callbacks are called. The parser helps by keeping track of objects created
  # by the callbacks but does not create those objects itself.
  #
  #    hash_start
  #
  # When a JSON object element starts the hash_start() callback is called if
  # public. It should return what ever Ruby Object is to be used as the element
  # that will later be included in the hash_set() callback.
  #
  #    hash_end
  #
  # When a hash key is encountered the hash_key method is called with the parsed
  # hash value key. The return value from the call is then used as the key in
  # the key-value pair that follows.
  #
  #    hash_key
  #
  # At the end of a JSON object element the hash_end() callback is called if public.
  #
  #    hash_set
  #
  # When a key value pair is encountered during parsing the hash_set() callback
  # is called if public. The first element will be the object returned from the
  # enclosing hash_start() callback. The second argument is the key and the last
  # is the value.
  #
  #    array_start
  #
  # When a JSON array element is started the array_start() callback is called if
  # public. It should return what ever Ruby Object is to be used as the element
  # that will later be included in the array_append() callback.
  #
  #    array_end
  #
  # At the end of a JSON array element the array_end() callback is called if public.
  #
  #    array_append
  #
  # When a element is encountered that is an element of an array the
  # array_append() callback is called if public. The first argument to the
  # callback is the Ruby object returned from the enclosing array_start()
  # callback.
  #
  #    add_value
  #
  # The handler is expected to handle multiple JSON elements in one stream,
  # file, or string. When a top level JSON has been read completely the
  # add_value() callback is called. Even if only one element was ready this
  # callback returns the Ruby object that was constructed during the parsing.
  #
  class ScHandler
    # Create a new instance of the ScHandler class.
    def initialize()
    end

    # To make the desired methods active while parsing the desired method should
    # be made public in the subclasses. If the methods remain private they will
    # not be called during parsing.
    private

    def hash_start()
    end

    def hash_end()
    end

    def hash_key(key)
      key
    end

    def hash_set(h, key, value)
    end

    def array_start()
    end

    def array_end()
    end

    def add_value(value)
    end

    def array_append(a, value)
    end

  end # ScHandler
end # Oj
