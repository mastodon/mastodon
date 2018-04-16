module Rack
  module Test
    module Utils # :nodoc:
      include Rack::Utils
      extend Rack::Utils

      def build_nested_query(value, prefix = nil)
        case value
        when Array
          if value.empty?
            "#{prefix}[]="
          else
            value.map do |v|
              prefix = "#{prefix}[]" unless unescape(prefix) =~ /\[\]$/
              build_nested_query(v, prefix.to_s)
            end.join('&')
          end
        when Hash
          value.map do |k, v|
            build_nested_query(v, prefix ? "#{prefix}[#{escape(k)}]" : escape(k))
          end.join('&')
        when NilClass
          prefix.to_s
        else
          "#{prefix}=#{escape(value)}"
        end
      end
      module_function :build_nested_query

      def build_multipart(params, first = true, multipart = false)
        if first
          raise ArgumentError, 'value must be a Hash' unless params.is_a?(Hash)

          query = lambda { |value|
            case value
            when Array
              value.each(&query)
            when Hash
              value.values.each(&query)
            when UploadedFile
              multipart = true
            end
          }
          params.values.each(&query)
          return nil unless multipart
        end

        flattened_params = {}

        params.each do |key, value|
          k = first ? key.to_s : "[#{key}]"

          case value
          when Array
            value.map do |v|
              if v.is_a?(Hash)
                nested_params = {}
                build_multipart(v, false).each do |subkey, subvalue|
                  nested_params[subkey] = subvalue
                end
                flattened_params["#{k}[]"] ||= []
                flattened_params["#{k}[]"] << nested_params
              else
                flattened_params["#{k}[]"] = value
              end
            end
          when Hash
            build_multipart(value, false).each do |subkey, subvalue|
              flattened_params[k + subkey] = subvalue
            end
          else
            flattened_params[k] = value
          end
        end

        if first
          build_parts(flattened_params)
        else
          flattened_params
        end
      end
      module_function :build_multipart

      private

      def build_parts(parameters)
        get_parts(parameters).join + "--#{MULTIPART_BOUNDARY}--\r"
      end
      module_function :build_parts

      def get_parts(parameters)
        parameters.map do |name, value|
          if name =~ /\[\]\Z/ && value.is_a?(Array) && value.all? { |v| v.is_a?(Hash) }
            value.map do |hash|
              new_value = {}
              hash.each { |k, v| new_value[name + k] = v }
              get_parts(new_value).join
            end.join
          else
            if value.respond_to?(:original_filename)
              build_file_part(name, value)

            elsif value.is_a?(Array) && value.all? { |v| v.respond_to?(:original_filename) }
              value.map do |v|
                build_file_part(name, v)
              end.join

            else
              primitive_part = build_primitive_part(name, value)
              Rack::Test.encoding_aware_strings? ? primitive_part.force_encoding('BINARY') : primitive_part
            end
          end
        end
      end
      module_function :get_parts

      def build_primitive_part(parameter_name, value)
        value = [value] unless value.is_a? Array
        value.map do |v|
          <<-EOF
--#{MULTIPART_BOUNDARY}\r
Content-Disposition: form-data; name="#{parameter_name}"\r
\r
#{v}\r
EOF
        end.join
      end
      module_function :build_primitive_part

      def build_file_part(parameter_name, uploaded_file)
        uploaded_file.set_encoding(Encoding::BINARY) if uploaded_file.respond_to?(:set_encoding)
        <<-EOF
--#{MULTIPART_BOUNDARY}\r
Content-Disposition: form-data; name="#{parameter_name}"; filename="#{escape(uploaded_file.original_filename)}"\r
Content-Type: #{uploaded_file.content_type}\r
Content-Length: #{uploaded_file.size}\r
\r
#{uploaded_file.read}\r
EOF
      end
      module_function :build_file_part
    end
  end
end
