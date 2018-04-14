require 'tilt/template'
require 'coffee_script'

module Tilt
  # CoffeeScript template implementation. See:
  # http://coffeescript.org/
  #
  # CoffeeScript templates do not support object scopes, locals, or yield.
  class CoffeeScriptTemplate < Template
    self.default_mime_type = 'application/javascript'

    @@default_bare = false

    def self.default_bare
      @@default_bare
    end

    def self.default_bare=(value)
      @@default_bare = value
    end

    # DEPRECATED
    def self.default_no_wrap
      @@default_bare
    end

    # DEPRECATED
    def self.default_no_wrap=(value)
      @@default_bare = value
    end

    def self.literate?
      false
    end

    def prepare
      if !options.key?(:bare) and !options.key?(:no_wrap)
        options[:bare] = self.class.default_bare
      end
      options[:literate] ||= self.class.literate?
    end

    def evaluate(scope, locals, &block)
      @output ||= CoffeeScript.compile(data, options)
    end

    def allows_script?
      false
    end
  end

  class CoffeeScriptLiterateTemplate < CoffeeScriptTemplate
    def self.literate?
      true
    end
  end
end

