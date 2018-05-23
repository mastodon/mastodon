require 'base64'
require 'time'

module Aws
  module Xml
    class Parser
      class Frame

        include Seahorse::Model::Shapes

        class << self

          def new(path, parent, ref, result = nil)
            if self == Frame
              frame = frame_class(ref).allocate
              frame.send(:initialize, path, parent, ref, result)
              frame
            else
              super
            end
          end

          private

          def frame_class(ref)
            klass = FRAME_CLASSES[ref.shape.class]
            if ListFrame == klass && ref.shape.flattened
              FlatListFrame
            elsif MapFrame == klass && ref.shape.flattened
              MapEntryFrame
            else
              klass
            end
          end

        end

        def initialize(path, parent, ref, result)
          @path = path
          @parent = parent
          @ref = ref
          @result = result
          @text = []
        end

        attr_reader :parent

        attr_reader :ref

        attr_reader :result

        def set_text(value)
          @text << value
        end

        def child_frame(xml_name)
          NullFrame.new(xml_name, self)
        end

        def consume_child_frame(child); end

        # @api private
        def path
          if Stack === parent
            [@path]
          else
            parent.path + [@path]
          end
        end

        # @api private
        def yield_unhandled_value(path, value)
          parent.yield_unhandled_value(path, value)
        end

      end

      class StructureFrame < Frame

        def initialize(xml_name, parent, ref, result = nil)
          super
          @result ||= ref.shape.struct_class.new
          @members = {}
          ref.shape.members.each do |member_name, member_ref|
            apply_default_value(member_name, member_ref)
            @members[xml_name(member_ref)] = {
              name: member_name,
              ref: member_ref,
            }
          end
        end

        def child_frame(xml_name)
          if @member = @members[xml_name]
            Frame.new(xml_name, self, @member[:ref])
          else
            NullFrame.new(xml_name, self)
          end
        end

        def consume_child_frame(child)
          case child
          when MapEntryFrame
            @result[@member[:name]][child.key.result] = child.value.result
          when FlatListFrame
            @result[@member[:name]] << child.result
          when NullFrame
          else
            @result[@member[:name]] = child.result
          end
        end

        private

        def apply_default_value(name, ref)
          case ref.shape
          when ListShape then @result[name] = DefaultList.new
          when MapShape then @result[name] = DefaultMap.new
          end
        end

        def xml_name(ref)
          if flattened_list?(ref.shape)
            ref.shape.member.location_name || ref.location_name
          else
            ref.location_name
          end
        end

        def flattened_list?(shape)
          ListShape === shape && shape.flattened
        end

      end

      class ListFrame < Frame

        def initialize(*args)
          super
          @result = []
          @member_xml_name = @ref.shape.member.location_name || 'member'
        end

        def child_frame(xml_name)
          if xml_name == @member_xml_name
            Frame.new(xml_name, self, @ref.shape.member)
          else
            raise NotImplementedError
          end
        end

        def consume_child_frame(child)
          @result << child.result unless NullFrame === child
        end

      end

      class FlatListFrame < Frame

        def initialize(xml_name, *args)
          super
          @member = Frame.new(xml_name, self, @ref.shape.member)
        end

        def result
          @member.result
        end

        def set_text(value)
          @member.set_text(value)
        end

        def child_frame(xml_name)
          @member.child_frame(xml_name)
        end

        def consume_child_frame(child)
          @result = @member.result
        end

      end

      class MapFrame < Frame

        def initialize(*args)
          super
          @result = {}
        end

        def child_frame(xml_name)
          if xml_name == 'entry'
            MapEntryFrame.new(xml_name, self, @ref)
          else
            raise NotImplementedError
          end
        end

        def consume_child_frame(child)
          @result[child.key.result] = child.value.result
        end

      end

      class MapEntryFrame < Frame

        def initialize(xml_name, *args)
          super
          @key_name = @ref.shape.key.location_name || 'key'
          @key = Frame.new(xml_name, self, @ref.shape.key)
          @value_name = @ref.shape.value.location_name || 'value'
          @value = Frame.new(xml_name, self, @ref.shape.value)
        end

        # @return [StringFrame]
        attr_reader :key

        # @return [Frame]
        attr_reader :value

        def child_frame(xml_name)
          if @key_name == xml_name
            @key
          elsif @value_name == xml_name
            @value
          else
            NullFrame.new(xml_name, self)
          end
        end

      end

      class NullFrame < Frame
        def self.new(xml_name, parent)
          super(xml_name, parent, nil, nil)
        end

        def set_text(value)
          yield_unhandled_value(path, value)
          super
        end
      end

      class BlobFrame < Frame
        def result
          @text.empty? ? nil : Base64.decode64(@text.join)
        end
      end

      class BooleanFrame < Frame
        def result
          @text.empty? ? nil : (@text.join == 'true')
        end
      end

      class FloatFrame < Frame
        def result
          @text.empty? ? nil : @text.join.to_f
        end
      end

      class IntegerFrame < Frame
        def result
          @text.empty? ? nil : @text.join.to_i
        end
      end

      class StringFrame < Frame
        def result
          @text.join
        end
      end

      class TimestampFrame < Frame
        def result
          @text.empty? ? nil : parse(@text.join)
        end
        def parse(value)
          case value
          when nil then nil
          when /^\d+$/ then Time.at(value.to_i)
          else
            begin
              Time.parse(value).utc
            rescue ArgumentError
              raise "unhandled timestamp format `#{value}'"
            end
          end
        end
      end

      include Seahorse::Model::Shapes

      FRAME_CLASSES = {
        NilClass => NullFrame,
        BlobShape => BlobFrame,
        BooleanShape => BooleanFrame,
        FloatShape => FloatFrame,
        IntegerShape => IntegerFrame,
        ListShape => ListFrame,
        MapShape => MapFrame,
        StringShape => StringFrame,
        StructureShape => StructureFrame,
        TimestampShape => TimestampFrame,
      }

    end
  end
end
