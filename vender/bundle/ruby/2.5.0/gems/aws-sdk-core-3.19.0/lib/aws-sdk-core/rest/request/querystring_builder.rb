module Aws
  module Rest
    module Request
      class QuerystringBuilder

        include Seahorse::Model::Shapes

        # Provide shape references and param values:
        #
        #     [
        #       [shape_ref1, 123],
        #       [shape_ref2, "text"]
        #     ]
        #
        # Returns a querystring:
        #
        #   "Count=123&Words=text"
        #
        # @param [Array<Array<Seahorse::Model::ShapeRef, Object>>] params An array of
        #   model shape references and request parameter value pairs.
        #
        # @return [String] Returns a built querystring
        def build(params)
          params.map do |(shape_ref, param_value)|
            build_part(shape_ref, param_value)
          end.join('&')
        end

        private

        def build_part(shape_ref, param_value)
          case shape_ref.shape
          # supported scalar types
          when StringShape, BooleanShape, FloatShape, IntegerShape, StringShape
            param_name = shape_ref.location_name
            "#{param_name}=#{escape(param_value.to_s)}"
          when TimestampShape
            param_name = shape_ref.location_name
            "#{param_name}=#{escape(param_value.utc.httpdate)}"
          when MapShape
            if StringShape === shape_ref.shape.value.shape
              query_map_of_string(param_value)
            elsif ListShape === shape_ref.shape.value.shape
              query_map_of_string_list(param_value)
            else
              msg = "only map of string and string list supported"
              raise NotImplementedError, msg
            end
          when ListShape
            if StringShape === shape_ref.shape.member.shape
              list_of_strings(shape_ref.location_name, param_value)
            else
              msg = "Only list of strings supported, got "
              msg << shape_ref.shape.member.shape.class.name
              raise NotImplementedError, msg
            end
          else
            raise NotImplementedError
          end
        end

        def query_map_of_string(hash)
          list = []
          hash.each_pair do |key, value|
            list << "#{escape(key)}=#{escape(value)}"
          end
          list
        end

        def query_map_of_string_list(hash)
          list = []
          hash.each_pair do |key, values|
            values.each do |value|
              list << "#{escape(key)}=#{escape(value)}"
            end
          end
          list
        end

        def list_of_strings(name, values)
          values.map do |value|
            "#{name}=#{escape(value)}"
          end
        end

        def escape(string)
          Seahorse::Util.uri_escape(string)
        end

      end
    end
  end
end
