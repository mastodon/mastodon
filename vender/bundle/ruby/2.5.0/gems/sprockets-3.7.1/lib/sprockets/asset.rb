require 'fileutils'
require 'sprockets/digest_utils'

module Sprockets
  class Asset
    attr_reader :logical_path

    # Private: Intialize Asset wrapper from attributes Hash.
    #
    # Asset wrappers should not be initialized directly, only
    # Environment#find_asset should vend them.
    #
    # attributes - Hash of ivars
    #
    # Returns Asset.
    def initialize(environment, attributes = {})
      @environment  = environment
      @attributes   = attributes
      @content_type = attributes[:content_type]
      @filename     = attributes[:filename]
      @id           = attributes[:id]
      @load_path    = attributes[:load_path]
      @logical_path = attributes[:logical_path]
      @metadata     = attributes[:metadata]
      @mtime        = attributes[:mtime]
      @name         = attributes[:name]
      @source       = attributes[:source]
      @uri          = attributes[:uri]
    end

    # Internal: Return all internal instance variables as a hash.
    #
    # Returns a Hash.
    def to_hash
      @attributes
    end

    # Public: Metadata accumulated from pipeline process.
    #
    # The API status of the keys is dependent on the pipeline processors
    # itself. So some values maybe considered public and others internal.
    # See the pipeline proccessor documentation itself.
    #
    # Returns Hash.
    attr_reader :metadata

    # Public: Returns String path of asset.
    attr_reader :filename

    # Internal: Unique asset object ID.
    #
    # Returns a String.
    attr_reader :id

    # Public: Internal URI to lookup asset by.
    #
    # NOT a publically accessible URL.
    #
    # Returns URI.
    attr_reader :uri

    # Public: Return logical path with digest spliced in.
    #
    #   "foo/bar-37b51d194a7513e45b56f6524f2d51f2.js"
    #
    # Returns String.
    def digest_path
      logical_path.sub(/\.(\w+)$/) { |ext| "-#{etag}#{ext}" }
    end

    # Public: Returns String MIME type of asset. Returns nil if type is unknown.
    attr_reader :content_type

    # Public: Get all externally linked asset filenames from asset.
    #
    # All linked assets should be compiled anytime this asset is.
    #
    # Returns Set of String asset URIs.
    def links
      metadata[:links] || Set.new
    end

    # Public: Get all internally required assets that were concated into this
    # asset.
    #
    # Returns Array of String asset URIs.
    def included
      metadata[:included]
    end

    # Public: Return `String` of concatenated source.
    #
    # Returns String.
    def source
      if @source
        @source
      else
        # File is read everytime to avoid memory bloat of large binary files
        File.binread(filename)
      end
    end

    # Public: Alias for #source.
    #
    # Returns String.
    def to_s
      source
    end

    # Public: Get charset of source.
    #
    # Returns a String charset name or nil if binary.
    def charset
      metadata[:charset]
    end

    # Public: Returns Integer length of source.
    def length
      metadata[:length]
    end
    alias_method :bytesize, :length

    # Public: Returns String hexdigest of source.
    def hexdigest
      DigestUtils.pack_hexdigest(metadata[:digest])
    end

    # Deprecated: Returns String hexdigest of source.
    #
    # In 4.x this will be changed to return a raw Digest byte String.
    alias_method :digest, :hexdigest

    # Pubic: ETag String of Asset.
    alias_method :etag, :hexdigest

    # Public: Returns String base64 digest of source.
    def base64digest
      DigestUtils.pack_base64digest(metadata[:digest])
    end

    # Public: A "named information" URL for subresource integrity.
    def integrity
      DigestUtils.integrity_uri(metadata[:digest])
    end

    # Public: Add enumerator to allow `Asset` instances to be used as Rack
    # compatible body objects.
    #
    # block
    #   part - String body chunk
    #
    # Returns nothing.
    def each
      yield to_s
    end

    # Deprecated: Save asset to disk.
    #
    # filename - String target
    #
    # Returns nothing.
    def write_to(filename)
      FileUtils.mkdir_p File.dirname(filename)

      PathUtils.atomic_write(filename) do |f|
        f.write source
      end

      # Set mtime correctly
      File.utime(mtime, mtime, filename)

      nil
    end

    # Public: Pretty inspect
    #
    # Returns String.
    def inspect
      "#<#{self.class}:#{object_id.to_s(16)} #{uri.inspect}>"
    end

    # Public: Implements Object#hash so Assets can be used as a Hash key or
    # in a Set.
    #
    # Returns Integer hash of the id.
    def hash
      id.hash
    end

    # Public: Compare assets.
    #
    # Assets are equal if they share the same path and digest.
    #
    # Returns true or false.
    def eql?(other)
      self.class == other.class && self.id == other.id
    end
    alias_method :==, :eql?
  end
end
