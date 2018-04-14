# frozen_string_literal: true

require "http/form_data/readable"
require "http/form_data/composite_io"

module HTTP
  module FormData
    class Multipart
      # Utility class to represent multi-part chunks
      class Param
        include Readable

        # Initializes body part with headers and data.
        #
        # @example With {FormData::File} value
        #
        #   Content-Disposition: form-data; name="avatar"; filename="avatar.png"
        #   Content-Type: application/octet-stream
        #
        #   ...data of avatar.png...
        #
        # @example With non-{FormData::File} value
        #
        #   Content-Disposition: form-data; name="username"
        #
        #   ixti
        #
        # @return [String]
        # @param [#to_s] name
        # @param [FormData::File, FormData::Part, #to_s] value
        def initialize(name, value)
          @name = name.to_s

          @part =
            if value.is_a?(FormData::Part)
              value
            else
              FormData::Part.new(value)
            end

          @io = CompositeIO.new [header, @part, footer]
        end

        # Flattens given `data` Hash into an array of `Param`'s.
        # Nested array are unwinded.
        # Behavior is similar to `URL.encode_www_form`.
        #
        # @param [Hash] data
        # @return [Array<FormData::MultiPart::Param>]
        def self.coerce(data)
          params = []

          data.each do |name, values|
            Array(values).each do |value|
              params << new(name, value)
            end
          end

          params
        end

        private

        def header
          header = "".b
          header << "Content-Disposition: form-data; #{parameters}#{CRLF}"
          header << "Content-Type: #{content_type}#{CRLF}" if content_type
          header << CRLF
          header
        end

        def parameters
          parameters = { :name => @name }
          parameters[:filename] = filename if filename
          parameters.map { |k, v| "#{k}=#{v.inspect}" }.join("; ")
        end

        def content_type
          @part.content_type
        end

        def filename
          @part.filename
        end

        def footer
          CRLF.dup
        end
      end
    end
  end
end
