require 'tilt/template'
require 'liquid'

module Tilt
  # Liquid template implementation. See:
  # http://liquidmarkup.org/
  #
  # Liquid is designed to be a *safe* template system and threfore
  # does not provide direct access to execuatable scopes. In order to
  # support a +scope+, the +scope+ must be able to represent itself
  # as a hash by responding to #to_h. If the +scope+ does not respond
  # to #to_h it will be ignored.
  #
  # LiquidTemplate does not support yield blocks.
  #
  # It's suggested that your program require 'liquid' at load
  # time when using this template engine.
  class LiquidTemplate < Template
    def prepare
      @engine = ::Liquid::Template.parse(data, liquid_options)
    end

    def evaluate(scope, locals, &block)
      locals = locals.inject({}){ |h,(k,v)| h[k.to_s] = v ; h }
      if scope.respond_to?(:to_h)
        scope  = scope.to_h.inject({}){ |h,(k,v)| h[k.to_s] = v ; h }
        locals = scope.merge(locals)
      end
      locals['yield'] = block.nil? ? '' : yield
      locals['content'] = locals['yield']
      @engine.render(locals)
    end

    def allows_script?
      false
    end

    private

    def liquid_options
      { line_numbers: true }.merge options
    end
  end
end
