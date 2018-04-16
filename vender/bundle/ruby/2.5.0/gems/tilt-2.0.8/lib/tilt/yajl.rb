require 'tilt/template'
require 'yajl'

module Tilt

  # Yajl Template implementation
  #
  # Yajl is a fast JSON parsing and encoding library for Ruby
  # See https://github.com/brianmario/yajl-ruby
  #
  # The template source is evaluated as a Ruby string,
  # and the result is converted #to_json.
  #
  # == Example
  #
  #    # This is a template example.
  #    # The template can contain any Ruby statement.
  #    tpl <<-EOS
  #      @counter = 0
  #
  #      # The json variable represents the buffer
  #      # and holds the data to be serialized into json.
  #      # It defaults to an empty hash, but you can override it at any time.
  #      json = {
  #        :"user#{@counter += 1}" => { :name => "Joshua Peek", :id => @counter },
  #        :"user#{@counter += 1}" => { :name => "Ryan Tomayko", :id => @counter },
  #        :"user#{@counter += 1}" => { :name => "Simone Carletti", :id => @counter },
  #      }
  #
  #      # Since the json variable is a Hash,
  #      # you can use conditional statements or any other Ruby statement
  #      # to populate it.
  #      json[:"user#{@counter += 1}"] = { :name => "Unknown" } if 1 == 2
  #
  #      # The last line doesn't affect the returned value.
  #      nil
  #    EOS
  #
  #    template = Tilt::YajlTemplate.new { tpl }
  #    template.render(self)
  #
  class YajlTemplate < Template

    self.default_mime_type = 'application/json'

    def prepare
    end

    def evaluate(scope, locals, &block)
      decorate super(scope, locals, &block)
    end

    def precompiled_preamble(locals)
      return super if locals.include? :json
      "json = {}\n#{super}"
    end

    def precompiled_postamble(locals)
      "Yajl::Encoder.new.encode(json)"
    end

    def precompiled_template(locals)
      data.to_str
    end


    # Decorates the +json+ input according to given +options+.
    #
    # json    - The json String to decorate.
    # options - The option Hash to customize the behavior.
    #
    # Returns the decorated String.
    def decorate(json)
      callback, variable = options[:callback], options[:variable]
      if callback && variable
        "var #{variable} = #{json}; #{callback}(#{variable});"
      elsif variable
        "var #{variable} = #{json};"
      elsif callback
        "#{callback}(#{json});"
      else
        json
      end
    end
  end

end
