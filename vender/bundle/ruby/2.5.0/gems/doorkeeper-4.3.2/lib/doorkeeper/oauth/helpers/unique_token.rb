module Doorkeeper
  module OAuth
    module Helpers
      module UniqueToken
        def self.generate(options = {})
          generator_method = options.delete(:generator) || SecureRandom.method(:hex)
          token_size       = options.delete(:size)      || 32
          generator_method.call(token_size)
        end
      end
    end
  end
end
