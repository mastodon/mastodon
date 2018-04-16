require 'tilt/template'
require 'babel/transpiler'

module Tilt
  class BabelTemplate < Template
    self.default_mime_type = 'application/javascript'

    def prepare
      options[:filename] ||= file
    end

    def evaluate(scope, locals, &block)
      @output ||= Babel::Transpiler.transform(data)["code"]
    end
  end
end
