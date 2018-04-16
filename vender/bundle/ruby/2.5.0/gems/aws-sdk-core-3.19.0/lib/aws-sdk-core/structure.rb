module Aws
  # @api private
  module Structure

    def initialize(values = {})
      values.each do |k, v|
        self[k] = v
      end
    end

    # @return [Boolean] Returns `true` if this structure has a value
    #   set for the given member.
    def key?(member_name)
      !self[member_name].nil?
    end

    # @return [Boolean] Returns `true` if all of the member values are `nil`.
    def empty?
      values.compact == []
    end

    # Deeply converts the Structure into a hash.  Structure members that
    # are `nil` are omitted from the resultant hash.
    #
    # You can call #orig_to_h to get vanilla #to_h behavior as defined
    # in stdlib Struct.
    #
    # @return [Hash]
    def to_h(obj = self)
      case obj
      when Struct
        obj.members.each.with_object({}) do |member, hash|
          value = obj[member]
          hash[member] = to_hash(value) unless value.nil?
        end
      when Hash
        obj.each.with_object({}) do |(key, value), hash|
          hash[key] = to_hash(value)
        end
      when Array
        obj.collect { |value| to_hash(value) }
      else
        obj
      end
    end
    alias to_hash to_h

    class << self

      # @api private
      def new(*args)
        if args.empty?
          Aws::EmptyStructure
        else
          struct = Struct.new(*args)
          struct.send(:include, Aws::Structure)
          struct
        end
      end

      # @api private
      def self.included(base_class)
        base_class.send(:undef_method, :each)
      end

    end
  end

  # @api private
  class EmptyStructure < Struct.new('AwsEmptyStructure')
    include(Aws::Structure)
  end

end
