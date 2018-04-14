module Hashie
  module Extensions
    # Searches a deeply nested datastructure for a key path, and returns the associated value.
    #
    #  options = { user: { location: { address: '123 Street' } } }
    #  options.deep_fetch :user, :location, :address #=> '123 Street'
    #
    # If a block is provided its value will be returned if the key does not exist.
    #
    #  options.deep_fetch(:user, :non_existent_key) { 'a value' } #=> 'a value'
    #
    # This is particularly useful for fetching values from deeply nested api responses or params hashes.
    module DeepFetch
      class UndefinedPathError < StandardError; end

      def deep_fetch(*args, &block)
        args.reduce(self) do |obj, arg|
          begin
            arg = Integer(arg) if obj.is_a? Array
            obj.fetch(arg)
          rescue ArgumentError, IndexError, NoMethodError => e
            break block.call(arg) if block
            raise UndefinedPathError, "Could not fetch path (#{args.join(' > ')}) at #{arg}", e.backtrace
          end
        end
      end
    end
  end
end
