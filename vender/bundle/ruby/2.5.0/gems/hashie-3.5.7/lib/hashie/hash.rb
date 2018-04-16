require 'hashie/extensions/stringify_keys'
require 'hashie/extensions/pretty_inspect'

module Hashie
  # A Hashie Hash is simply a Hash that has convenience
  # functions baked in such as stringify_keys that may
  # not be available in all libraries.
  class Hash < ::Hash
    include Hashie::Extensions::PrettyInspect
    include Hashie::Extensions::StringifyKeys

    # Convert this hash into a Mash
    def to_mash
      ::Hashie::Mash.new(self)
    end

    # Converts a mash back to a hash (with stringified or symbolized keys)
    def to_hash(options = {})
      out = {}
      keys.each do |k|
        assignment_key = if options[:stringify_keys]
                           k.to_s
                         elsif options[:symbolize_keys]
                           k.to_s.to_sym
                         else
                           k
                         end
        if self[k].is_a?(Array)
          out[assignment_key] ||= []
          self[k].each do |array_object|
            out[assignment_key] << (Hash === array_object ? flexibly_convert_to_hash(array_object, options) : array_object)
          end
        else
          out[assignment_key] = (Hash === self[k] || self[k].respond_to?(:to_hash)) ? flexibly_convert_to_hash(self[k], options) : self[k]
        end
      end
      out
    end

    # The C generator for the json gem doesn't like mashies
    def to_json(*args)
      to_hash.to_json(*args)
    end

    private

    def flexibly_convert_to_hash(object, options = {})
      if object.method(:to_hash).arity == 0
        object.to_hash
      else
        object.to_hash(options)
      end
    end
  end
end
