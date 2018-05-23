##
module MIME
  ##
  class Types
    unless private_method_defined?(:load_mode)
      class << self
        private

        def load_mode
          { columnar: false }
        end
      end
    end
  end
end

require 'mime/types'
