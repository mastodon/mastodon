module Lograge
  module Formatters
    class Lines
      def call(data)
        load_dependencies

        ::Lines.dump(data)
      end

      def load_dependencies
        require 'lines'
      rescue LoadError
        puts 'You need to install the lines gem to use this output.'
        raise
      end
    end
  end
end
