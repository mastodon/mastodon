require 'sprockets/encoding_utils'
require 'sprockets/http_utils'
require 'sprockets/utils'

module Sprockets
  module Mime
    include HTTPUtils, Utils

    # Public: Mapping of MIME type Strings to properties Hash.
    #
    # key   - MIME Type String
    # value - Hash
    #   extensions - Array of extnames
    #   charset    - Default Encoding or function to detect encoding
    #
    # Returns Hash.
    def mime_types
      config[:mime_types]
    end

    # Internal: Mapping of MIME extension Strings to MIME type Strings.
    #
    # Used for internal fast lookup purposes.
    #
    # Examples:
    #
    #   mime_exts['.js'] #=> 'application/javascript'
    #
    # key   - MIME extension String
    # value - MIME Type String
    #
    # Returns Hash.
    def mime_exts
      config[:mime_exts]
    end

    # Public: Register a new mime type.
    #
    # mime_type - String MIME Type
    # options - Hash
    #   extensions: Array of String extnames
    #   charset: Proc/Method that detects the charset of a file.
    #            See EncodingUtils.
    #
    # Returns nothing.
    def register_mime_type(mime_type, options = {})
      # Legacy extension argument, will be removed from 4.x
      if options.is_a?(String)
        options = { extensions: [options] }
      end

      extnames = Array(options[:extensions]).map { |extname|
        Sprockets::Utils.normalize_extension(extname)
      }

      charset = options[:charset]
      charset ||= :default if mime_type.start_with?('text/')
      charset = EncodingUtils::CHARSET_DETECT[charset] if charset.is_a?(Symbol)

      self.computed_config = {}

      self.config = hash_reassoc(config, :mime_exts) do |mime_exts|
        extnames.each do |extname|
          mime_exts[extname] = mime_type
        end
        mime_exts
      end

      self.config = hash_reassoc(config, :mime_types) do |mime_types|
        type = { extensions: extnames }
        type[:charset] = charset if charset
        mime_types.merge(mime_type => type)
      end
    end

    # Internal: Get detecter function for MIME type.
    #
    # mime_type - String MIME type
    #
    # Returns Proc detector or nil if none is available.
    def mime_type_charset_detecter(mime_type)
      if type = config[:mime_types][mime_type]
        if detect = type[:charset]
          return detect
        end
      end
    end

    # Public: Read file on disk with MIME type specific encoding.
    #
    # filename     - String path
    # content_type - String MIME type
    #
    # Returns String file contents transcoded to UTF-8 or in its external
    # encoding.
    def read_file(filename, content_type = nil)
      data = File.binread(filename)

      if detect = mime_type_charset_detecter(content_type)
        detect.call(data).encode(Encoding::UTF_8, :universal_newline => true)
      else
        data
      end
    end

    private
      def extname_map
        self.computed_config[:_extnames] ||= compute_extname_map
      end

      def compute_extname_map
        graph = {}

        ([nil] + pipelines.keys.map(&:to_s)).each do |pipeline|
          pipeline_extname = ".#{pipeline}" if pipeline
          ([[nil, nil]] + config[:mime_exts].to_a).each do |format_extname, format_type|
            4.times do |n|
              config[:engines].keys.permutation(n).each do |engine_extnames|
                key = "#{pipeline_extname}#{format_extname}#{engine_extnames.join}"
                type = format_type || config[:engine_mime_types][engine_extnames.first]
                graph[key] = {type: type, engines: engine_extnames, pipeline: pipeline}
              end
            end
          end
        end

        graph
      end
  end
end
