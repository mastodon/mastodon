module Hashie
  module Extensions
    # SRP: This extension will fail an error whenever a key is accessed that does not exist in the hash.
    #
    #   EXAMPLE:
    #
    #     class StrictKeyAccessHash < Hash
    #       include Hashie::Extensions::StrictKeyAccess
    #     end
    #
    #     >> hash = StrictKeyAccessHash[foo: "bar"]
    #     => {:foo=>"bar"}
    #     >> hash[:foo]
    #     => "bar"
    #     >> hash[:cow]
    #       KeyError: key not found: :cow
    #
    # NOTE: For googlers coming from Python to Ruby, this extension makes a Hash behave more like a "Dictionary".
    #
    module StrictKeyAccess
      class DefaultError < StandardError
        def initialize(msg = 'Setting or using a default with Hashie::Extensions::StrictKeyAccess does not make sense', *args)
          super
        end
      end

      # NOTE: Defaults don't make any sense with a StrictKeyAccess.
      # NOTE: When key lookup fails a KeyError is raised.
      #
      # Normal:
      #
      #     >> a = Hash.new(123)
      #     => {}
      #     >> a["noes"]
      #     => 123
      #
      # With StrictKeyAccess:
      #
      #     >> a = StrictKeyAccessHash.new(123)
      #     => {}
      #     >> a["noes"]
      #       KeyError: key not found: "noes"
      #
      def [](key)
        fetch(key)
      end

      def default(_ = nil)
        fail DefaultError
      end

      def default=(_)
        fail DefaultError
      end

      def default_proc
        fail DefaultError
      end

      def default_proc=(_)
        fail DefaultError
      end

      def key(value)
        result = super
        if result.nil? && (!key?(result) || self[result] != value)
          fail KeyError, "key not found with value of #{value.inspect}"
        else
          result
        end
      end
    end
  end
end
