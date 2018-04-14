module Aws
  # @api private
  class ParamValidator

    include Seahorse::Model::Shapes

    EXPECTED_GOT = "expected %s to be %s, got value %s (class: %s) instead."

    # @param [Seahorse::Model::Shapes::ShapeRef] rules
    # @param [Hash] params
    # @return [void]
    def self.validate!(rules, params)
      new(rules).validate!(params)
    end

    # @param [Seahorse::Model::Shapes::ShapeRef] rules
    # @option options [Boolean] :validate_required (true)
    def initialize(rules, options = {})
      @rules = rules || begin
        shape = StructureShape.new
        shape.struct_class = EmptyStructure
        ShapeRef.new(shape: shape)
      end
      @validate_required = options[:validate_required] != false
    end

    # @param [Hash] params
    # @return [void]
    def validate!(params)
      errors = []
      structure(@rules, params, errors, 'params') if @rules
      raise ArgumentError, error_messages(errors) unless errors.empty?
    end

    private

    def structure(ref, values, errors, context)
      # ensure the value is hash like
      return unless correct_type?(ref, values, errors, context)

      shape = ref.shape

      # ensure required members are present
      if @validate_required
        shape.required.each do |member_name|
          if values[member_name].nil?
            param = "#{context}[#{member_name.inspect}]"
            errors << "missing required parameter #{param}"
          end
        end
      end

      # validate non-nil members
      values.each_pair do |name, value|
        unless value.nil?
          if shape.member?(name)
            member_ref = shape.member(name)
            shape(member_ref, value, errors, context + "[#{name.inspect}]")
          else
            errors << "unexpected value at #{context}[#{name.inspect}]"
          end
        end
      end
    end

    def list(ref, values, errors, context)
      # ensure the value is an array
      unless values.is_a?(Array)
        errors << expected_got(context, "an Array", values)
        return
      end

      # validate members
      member_ref = ref.shape.member
      values.each.with_index do |value, index|
        shape(member_ref, value, errors, context + "[#{index}]")
      end
    end

    def map(ref, values, errors, context)
      unless Hash === values
        errors << expected_got(context, "a hash", values)
        return
      end

      key_ref = ref.shape.key
      value_ref = ref.shape.value

      values.each do |key, value|
        shape(key_ref, key, errors, "#{context} #{key.inspect} key")
        shape(value_ref, value, errors, context + "[#{key.inspect}]")
      end
    end

    def shape(ref, value, errors, context)
      case ref.shape
      when StructureShape then structure(ref, value, errors, context)
      when ListShape then list(ref, value, errors, context)
      when MapShape then map(ref, value, errors, context)
      when StringShape
        unless value.is_a?(String)
          errors << expected_got(context, "a String", value)
        end
      when IntegerShape
        unless value.is_a?(Integer)
          errors << expected_got(context, "an Integer", value)
        end
      when FloatShape
        unless value.is_a?(Float)
          errors << expected_got(context, "a Float", value)
        end
      when TimestampShape
        unless value.is_a?(Time)
          errors << expected_got(context, "a Time object", value)
        end
      when BooleanShape
        unless [true, false].include?(value)
          errors << expected_got(context, "true or false", value)
        end
      when BlobShape
        unless io_like?(value) or value.is_a?(String)
          errors << expected_got(context, "a String or IO object", value)
        end
      else
        raise "unhandled shape type: #{ref.shape.class.name}"
      end
    end

    def correct_type?(ref, value, errors, context)
      case value
      when Hash then true
      when ref.shape.struct_class then true
      else
        errors << expected_got(context, "a hash", value)
        false
      end
    end

    def io_like?(value)
      value.respond_to?(:read) &&
      value.respond_to?(:rewind) &&
      value.respond_to?(:size)
    end

    def error_messages(errors)
      if errors.size == 1
        errors.first
      else
        prefix = "\n  - "
        "parameter validator found #{errors.size} errors:" +
          prefix + errors.join(prefix)
      end
    end

    def expected_got(context, expected, got)
      EXPECTED_GOT % [context, expected, got.inspect, got.class.name]
    end

  end
end
