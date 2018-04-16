module MessagePack
  class Unpacker
    # see ext for other methods

    def registered_types
      list = []

      registered_types_internal.each_pair do |type, ary|
        list << {type: type, class: ary[0], unpacker: ary[2]}
      end

      list.sort{|a, b| a[:type] <=> b[:type] }
    end

    def type_registered?(klass_or_type)
      case klass_or_type
      when Class
        klass = klass_or_type
        registered_types.any?{|entry| klass == entry[:class] }
      when Integer
        type = klass_or_type
        registered_types.any?{|entry| type == entry[:type] }
      else
        raise ArgumentError, "class or type id"
      end
    end
  end
end
