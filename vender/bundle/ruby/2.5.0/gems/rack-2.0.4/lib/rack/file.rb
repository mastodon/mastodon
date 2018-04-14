require 'time'
require 'rack/utils'
require 'rack/mime'
require 'rack/request'
require 'rack/head'

module Rack
  # Rack::File serves files below the +root+ directory given, according to the
  # path info of the Rack request.
  # e.g. when Rack::File.new("/etc") is used, you can access 'passwd' file
  # as http://localhost:9292/passwd
  #
  # Handlers can detect if bodies are a Rack::File, and use mechanisms
  # like sendfile on the +path+.

  class File
    ALLOWED_VERBS = %w[GET HEAD OPTIONS]
    ALLOW_HEADER = ALLOWED_VERBS.join(', ')

    attr_reader :root

    def initialize(root, headers={}, default_mime = 'text/plain')
      @root = root
      @headers = headers
      @default_mime = default_mime
      @head = Rack::Head.new(lambda { |env| get env })
    end

    def call(env)
      # HEAD requests drop the response body, including 4xx error messages.
      @head.call env
    end

    def get(env)
      request = Rack::Request.new env
      unless ALLOWED_VERBS.include? request.request_method
        return fail(405, "Method Not Allowed", {'Allow' => ALLOW_HEADER})
      end

      path_info = Utils.unescape_path request.path_info
      return fail(400, "Bad Request") unless Utils.valid_path?(path_info)

      clean_path_info = Utils.clean_path_info(path_info)
      path = ::File.join(@root, clean_path_info)

      available = begin
        ::File.file?(path) && ::File.readable?(path)
      rescue SystemCallError
        false
      end

      if available
        serving(request, path)
      else
        fail(404, "File not found: #{path_info}")
      end
    end

    def serving(request, path)
      if request.options?
        return [200, {'Allow' => ALLOW_HEADER, CONTENT_LENGTH => '0'}, []]
      end
      last_modified = ::File.mtime(path).httpdate
      return [304, {}, []] if request.get_header('HTTP_IF_MODIFIED_SINCE') == last_modified

      headers = { "Last-Modified" => last_modified }
      mime_type = mime_type path, @default_mime
      headers[CONTENT_TYPE] = mime_type if mime_type

      # Set custom headers
      @headers.each { |field, content| headers[field] = content } if @headers

      response = [ 200, headers ]

      size = filesize path

      range = nil
      ranges = Rack::Utils.get_byte_ranges(request.get_header('HTTP_RANGE'), size)
      if ranges.nil? || ranges.length > 1
        # No ranges, or multiple ranges (which we don't support):
        # TODO: Support multiple byte-ranges
        response[0] = 200
        range = 0..size-1
      elsif ranges.empty?
        # Unsatisfiable. Return error, and file size:
        response = fail(416, "Byte range unsatisfiable")
        response[1]["Content-Range"] = "bytes */#{size}"
        return response
      else
        # Partial content:
        range = ranges[0]
        response[0] = 206
        response[1]["Content-Range"] = "bytes #{range.begin}-#{range.end}/#{size}"
        size = range.end - range.begin + 1
      end

      response[2] = [response_body] unless response_body.nil?

      response[1][CONTENT_LENGTH] = size.to_s
      response[2] = make_body request, path, range
      response
    end

    class Iterator
      attr_reader :path, :range
      alias :to_path :path

      def initialize path, range
        @path  = path
        @range = range
      end

      def each
        ::File.open(path, "rb") do |file|
          file.seek(range.begin)
          remaining_len = range.end-range.begin+1
          while remaining_len > 0
            part = file.read([8192, remaining_len].min)
            break unless part
            remaining_len -= part.length

            yield part
          end
        end
      end

      def close; end
    end

    private

    def make_body request, path, range
      if request.head?
        []
      else
        Iterator.new path, range
      end
    end

    def fail(status, body, headers = {})
      body += "\n"

      [
        status,
        {
          CONTENT_TYPE   => "text/plain",
          CONTENT_LENGTH => body.size.to_s,
          "X-Cascade" => "pass"
        }.merge!(headers),
        [body]
      ]
    end

    # The MIME type for the contents of the file located at @path
    def mime_type path, default_mime
      Mime.mime_type(::File.extname(path), default_mime)
    end

    def filesize path
      # If response_body is present, use its size.
      return response_body.bytesize if response_body

      #   We check via File::size? whether this file provides size info
      #   via stat (e.g. /proc files often don't), otherwise we have to
      #   figure it out by reading the whole file into memory.
      ::File.size?(path) || ::File.read(path).bytesize
    end

    # By default, the response body for file requests is nil.
    # In this case, the response body will be generated later
    # from the file at @path
    def response_body
      nil
    end
  end
end
