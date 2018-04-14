require 'tilt/template'
require 'typescript-node'

module Tilt
  class TypeScriptTemplate < Template
    self.default_mime_type = 'application/javascript'

    def prepare
      @option_args = []

      options.each do |key, value|
        next unless value

        @option_args << "--#{key}"

        if value != true
          @option_args << value.to_s
        end
      end
    end

    def evaluate(scope, locals, &block)
      @output ||= TypeScript::Node.compile(data, *@option_args)
    end
  end
end
