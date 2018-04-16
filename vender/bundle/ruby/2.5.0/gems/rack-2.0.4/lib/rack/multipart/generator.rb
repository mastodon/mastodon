module Rack
  module Multipart
    class Generator
      def initialize(params, first = true)
        @params, @first = params, first

        if @first && !@params.is_a?(Hash)
          raise ArgumentError, "value must be a Hash"
        end
      end

      def dump
        return nil if @first && !multipart?
        return flattened_params unless @first

        flattened_params.map do |name, file|
          if file.respond_to?(:original_filename)
            ::File.open(file.path, 'rb') do |f|
              f.set_encoding(Encoding::BINARY)
              content_for_tempfile(f, file, name)
            end
          else
            content_for_other(file, name)
          end
        end.join << "--#{MULTIPART_BOUNDARY}--\r"
      end

      private
      def multipart?
        multipart = false

        query = lambda { |value|
          case value
          when Array
            value.each(&query)
          when Hash
            value.values.each(&query)
          when Rack::Multipart::UploadedFile
            multipart = true
          end
        }
        @params.values.each(&query)

        multipart
      end

      def flattened_params
        @flattened_params ||= begin
          h = Hash.new
          @params.each do |key, value|
            k = @first ? key.to_s : "[#{key}]"

            case value
            when Array
              value.map { |v|
                Multipart.build_multipart(v, false).each { |subkey, subvalue|
                  h["#{k}[]#{subkey}"] = subvalue
                }
              }
            when Hash
              Multipart.build_multipart(value, false).each { |subkey, subvalue|
                h[k + subkey] = subvalue
              }
            else
              h[k] = value
            end
          end
          h
        end
      end

      def content_for_tempfile(io, file, name)
<<-EOF
--#{MULTIPART_BOUNDARY}\r
Content-Disposition: form-data; name="#{name}"; filename="#{Utils.escape(file.original_filename)}"\r
Content-Type: #{file.content_type}\r
Content-Length: #{::File.stat(file.path).size}\r
\r
#{io.read}\r
EOF
      end

      def content_for_other(file, name)
<<-EOF
--#{MULTIPART_BOUNDARY}\r
Content-Disposition: form-data; name="#{name}"\r
\r
#{file}\r
EOF
      end
    end
  end
end
