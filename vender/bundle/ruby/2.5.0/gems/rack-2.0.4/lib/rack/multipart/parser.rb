require 'rack/utils'

module Rack
  module Multipart
    class MultipartPartLimitError < Errno::EMFILE; end

    class Parser
      BUFSIZE = 1_048_576
      TEXT_PLAIN = "text/plain"
      TEMPFILE_FACTORY = lambda { |filename, content_type|
        Tempfile.new(["RackMultipart", ::File.extname(filename.gsub("\0".freeze, '%00'.freeze))])
      }

      class BoundedIO # :nodoc:
        def initialize(io, content_length)
          @io             = io
          @content_length = content_length
          @cursor = 0
        end

        def read(size)
          return if @cursor >= @content_length

          left = @content_length - @cursor

          str = if left < size
                  @io.read left
                else
                  @io.read size
                end

          if str
            @cursor += str.bytesize
          else
            # Raise an error for mismatching Content-Length and actual contents
            raise EOFError, "bad content body"
          end

          str
        end

        def eof?; @content_length == @cursor; end

        def rewind
          @io.rewind
        end
      end

      MultipartInfo = Struct.new :params, :tmp_files
      EMPTY         = MultipartInfo.new(nil, [])

      def self.parse_boundary(content_type)
        return unless content_type
        data = content_type.match(MULTIPART)
        return unless data
        data[1]
      end

      def self.parse(io, content_length, content_type, tmpfile, bufsize, qp)
        return EMPTY if 0 == content_length

        boundary = parse_boundary content_type
        return EMPTY unless boundary

        io = BoundedIO.new(io, content_length) if content_length

        parser = new(boundary, tmpfile, bufsize, qp)
        parser.on_read io.read(bufsize), io.eof?

        loop do
          break if parser.state == :DONE
          parser.on_read io.read(bufsize), io.eof?
        end

        io.rewind
        parser.result
      end

      class Collector
        class MimePart < Struct.new(:body, :head, :filename, :content_type, :name)
          def get_data
            data = body
            if filename == ""
              # filename is blank which means no file has been selected
              return
            elsif filename
              body.rewind if body.respond_to?(:rewind)

              # Take the basename of the upload's original filename.
              # This handles the full Windows paths given by Internet Explorer
              # (and perhaps other broken user agents) without affecting
              # those which give the lone filename.
              fn = filename.split(/[\/\\]/).last

              data = {:filename => fn, :type => content_type,
                      :name => name, :tempfile => body, :head => head}
            elsif !filename && content_type && body.is_a?(IO)
              body.rewind

              # Generic multipart cases, not coming from a form
              data = {:type => content_type,
                      :name => name, :tempfile => body, :head => head}
            end

            yield data
          end
        end

        class BufferPart < MimePart
          def file?; false; end
          def close; end
        end

        class TempfilePart < MimePart
          def file?; true; end
          def close; body.close; end
        end

        include Enumerable

        def initialize tempfile
          @tempfile = tempfile
          @mime_parts = []
          @open_files = 0
        end

        def each
          @mime_parts.each { |part| yield part }
        end

        def on_mime_head mime_index, head, filename, content_type, name
          if filename
            body = @tempfile.call(filename, content_type)
            body.binmode if body.respond_to?(:binmode)
            klass = TempfilePart
            @open_files += 1
          else
            body = String.new
            klass = BufferPart
          end

          @mime_parts[mime_index] = klass.new(body, head, filename, content_type, name)
          check_open_files
        end

        def on_mime_body mime_index, content
          @mime_parts[mime_index].body << content
        end

        def on_mime_finish mime_index
        end

        private

        def check_open_files
          if Utils.multipart_part_limit > 0
            if @open_files >= Utils.multipart_part_limit
              @mime_parts.each(&:close)
              raise MultipartPartLimitError, 'Maximum file multiparts in content reached'
            end
          end
        end
      end

      attr_reader :state

      def initialize(boundary, tempfile, bufsize, query_parser)
        @buf            = String.new

        @query_parser   = query_parser
        @params         = query_parser.make_params
        @boundary       = "--#{boundary}"
        @bufsize        = bufsize

        @rx = /(?:#{EOL})?#{Regexp.quote(@boundary)}(#{EOL}|--)/n
        @rx_max_size = EOL.size + @boundary.bytesize + [EOL.size, '--'.size].max
        @full_boundary = @boundary
        @end_boundary = @boundary + '--'
        @state = :FAST_FORWARD
        @mime_index = 0
        @collector = Collector.new tempfile
      end

      def on_read content, eof
        handle_empty_content!(content, eof)
        @buf << content
        run_parser
      end

      def result
        @collector.each do |part|
          part.get_data do |data|
            tag_multipart_encoding(part.filename, part.content_type, part.name, data)
            @query_parser.normalize_params(@params, part.name, data, @query_parser.param_depth_limit)
          end
        end

        MultipartInfo.new @params.to_params_hash, @collector.find_all(&:file?).map(&:body)
      end

      private

      def run_parser
        loop do
          case @state
          when :FAST_FORWARD
            break if handle_fast_forward == :want_read
          when :CONSUME_TOKEN
            break if handle_consume_token == :want_read
          when :MIME_HEAD
            break if handle_mime_head == :want_read
          when :MIME_BODY
            break if handle_mime_body == :want_read
          when :DONE
            break
          end
        end
      end

      def handle_fast_forward
        if consume_boundary
          @state = :MIME_HEAD
        else
          raise EOFError, "bad content body" if @buf.bytesize >= @bufsize
          :want_read
        end
      end

      def handle_consume_token
        tok = consume_boundary
        # break if we're at the end of a buffer, but not if it is the end of a field
        if tok == :END_BOUNDARY || (@buf.empty? && tok != :BOUNDARY)
          @state = :DONE
        else
          @state = :MIME_HEAD
        end
      end

      def handle_mime_head
        if @buf.index(EOL + EOL)
          i = @buf.index(EOL+EOL)
          head = @buf.slice!(0, i+2) # First \r\n
          @buf.slice!(0, 2)          # Second \r\n

          content_type = head[MULTIPART_CONTENT_TYPE, 1]
          if name = head[MULTIPART_CONTENT_DISPOSITION, 1]
            name = Rack::Auth::Digest::Params::dequote(name)
          else
            name = head[MULTIPART_CONTENT_ID, 1]
          end

          filename = get_filename(head)

          if name.nil? || name.empty?
            name = filename || "#{content_type || TEXT_PLAIN}[]"
          end

          @collector.on_mime_head @mime_index, head, filename, content_type, name
          @state = :MIME_BODY
        else
          :want_read
        end
      end

      def handle_mime_body
        if i = @buf.index(rx)
          # Save the rest.
          @collector.on_mime_body @mime_index, @buf.slice!(0, i)
          @buf.slice!(0, 2) # Remove \r\n after the content
          @state = :CONSUME_TOKEN
          @mime_index += 1
        else
          # Save the read body part.
          if @rx_max_size < @buf.size
            @collector.on_mime_body @mime_index, @buf.slice!(0, @buf.size - @rx_max_size)
          end
          :want_read
        end
      end

      def full_boundary; @full_boundary; end

      def rx; @rx; end

      def consume_boundary
        while @buf.gsub!(/\A([^\n]*(?:\n|\Z))/, '')
          read_buffer = $1
          case read_buffer.strip
          when full_boundary then return :BOUNDARY
          when @end_boundary then return :END_BOUNDARY
          end
          return if @buf.empty?
        end
      end

      def get_filename(head)
        filename = nil
        case head
        when RFC2183
          params = Hash[*head.scan(DISPPARM).flat_map(&:compact)]

          if filename = params['filename']
            filename = $1 if filename =~ /^"(.*)"$/
          elsif filename = params['filename*']
            encoding, _, filename = filename.split("'", 3)
          end
        when BROKEN_QUOTED, BROKEN_UNQUOTED
          filename = $1
        end

        return unless filename

        if filename.scan(/%.?.?/).all? { |s| s =~ /%[0-9a-fA-F]{2}/ }
          filename = Utils.unescape(filename)
        end

        filename.scrub!

        if filename !~ /\\[^\\"]/
          filename = filename.gsub(/\\(.)/, '\1')
        end

        if encoding
          filename.force_encoding ::Encoding.find(encoding)
        end

        filename
      end

      CHARSET   = "charset"

      def tag_multipart_encoding(filename, content_type, name, body)
        name = name.to_s
        encoding = Encoding::UTF_8

        name.force_encoding(encoding)

        return if filename

        if content_type
          list         = content_type.split(';')
          type_subtype = list.first
          type_subtype.strip!
          if TEXT_PLAIN == type_subtype
            rest         = list.drop 1
            rest.each do |param|
              k,v = param.split('=', 2)
              k.strip!
              v.strip!
              v = v[1..-2] if v[0] == '"' && v[-1] == '"'
              encoding = Encoding.find v if k == CHARSET
            end
          end
        end

        name.force_encoding(encoding)
        body.force_encoding(encoding)
      end


      def handle_empty_content!(content, eof)
        if content.nil? || content.empty?
          raise EOFError if eof
          return true
        end
      end
    end
  end
end
