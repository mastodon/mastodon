require 'fileutils'
require 'logger'
require 'sprockets/encoding_utils'
require 'sprockets/path_utils'
require 'zlib'

module Sprockets
  class Cache
    # Public: A file system cache store that automatically cleans up old keys.
    #
    # Assign the instance to the Environment#cache.
    #
    #     environment.cache = Sprockets::Cache::FileStore.new("/tmp")
    #
    # See Also
    #
    #   ActiveSupport::Cache::FileStore
    #
    class FileStore
      # Internal: Default key limit for store.
      DEFAULT_MAX_SIZE = 25 * 1024 * 1024

      # Internal: Default standard error fatal logger.
      #
      # Returns a Logger.
      def self.default_logger
        logger = Logger.new($stderr)
        logger.level = Logger::FATAL
        logger
      end

      # Public: Initialize the cache store.
      #
      # root     - A String path to a directory to persist cached values to.
      # max_size - A Integer of the maximum number of keys the store will hold.
      #            (default: 1000).
      def initialize(root, max_size = DEFAULT_MAX_SIZE, logger = self.class.default_logger)
        @root     = root
        @max_size = max_size
        @gc_size  = max_size * 0.75
        @logger   = logger
      end

      # Public: Retrieve value from cache.
      #
      # This API should not be used directly, but via the Cache wrapper API.
      #
      # key - String cache key.
      #
      # Returns Object or nil or the value is not set.
      def get(key)
        path = File.join(@root, "#{key}.cache")

        value = safe_open(path) do |f|
          begin
            EncodingUtils.unmarshaled_deflated(f.read, Zlib::MAX_WBITS)
          rescue Exception => e
            @logger.error do
              "#{self.class}[#{path}] could not be unmarshaled: " +
                "#{e.class}: #{e.message}"
            end
            nil
          end
        end

        if value
          FileUtils.touch(path)
          value
        end
      end

      # Public: Set a key and value in the cache.
      #
      # This API should not be used directly, but via the Cache wrapper API.
      #
      # key   - String cache key.
      # value - Object value.
      #
      # Returns Object value.
      def set(key, value)
        path = File.join(@root, "#{key}.cache")

        # Ensure directory exists
        FileUtils.mkdir_p File.dirname(path)

        # Check if cache exists before writing
        exists = File.exist?(path)

        # Serialize value
        marshaled = Marshal.dump(value)

        # Compress if larger than 4KB
        if marshaled.bytesize > 4 * 1024
          deflater = Zlib::Deflate.new(
            Zlib::BEST_COMPRESSION,
            Zlib::MAX_WBITS,
            Zlib::MAX_MEM_LEVEL,
            Zlib::DEFAULT_STRATEGY
          )
          deflater << marshaled
          raw = deflater.finish
        else
          raw = marshaled
        end

        # Write data
        PathUtils.atomic_write(path) do |f|
          f.write(raw)
          @size = size + f.size unless exists
        end

        # GC if necessary
        gc! if size > @max_size

        value
      end

      # Public: Pretty inspect
      #
      # Returns String.
      def inspect
        "#<#{self.class} size=#{size}/#{@max_size}>"
      end

      private
        # Internal: Get all cache files along with stats.
        #
        # Returns an Array of [String filename, File::Stat] pairs sorted by
        # mtime.
        def find_caches
          Dir.glob(File.join(@root, '**/*.cache')).reduce([]) { |stats, filename|
            stat = safe_stat(filename)
            # stat maybe nil if file was removed between the time we called
            # dir.glob and the next stat
            stats << [filename, stat] if stat
            stats
          }.sort_by { |_, stat| stat.mtime.to_i }
        end

        def size
          @size ||= compute_size(find_caches)
        end

        def compute_size(caches)
          caches.inject(0) { |sum, (_, stat)| sum + stat.size }
        end

        def safe_stat(fn)
          File.stat(fn)
        rescue Errno::ENOENT
          nil
        end

        def safe_open(path, &block)
          if File.exist?(path)
            File.open(path, 'rb', &block)
          end
        rescue Errno::ENOENT
        end

        def gc!
          start_time = Time.now

          caches = find_caches
          size = compute_size(caches)

          delete_caches, keep_caches = caches.partition { |filename, stat|
            deleted = size > @gc_size
            size -= stat.size
            deleted
          }

          return if delete_caches.empty?

          FileUtils.remove(delete_caches.map(&:first), force: true)
          @size = compute_size(keep_caches)

          @logger.warn do
            secs = Time.now.to_f - start_time.to_f
            "#{self.class}[#{@root}] garbage collected " +
              "#{delete_caches.size} files (#{(secs * 1000).to_i}ms)"
          end
        end
    end
  end
end
