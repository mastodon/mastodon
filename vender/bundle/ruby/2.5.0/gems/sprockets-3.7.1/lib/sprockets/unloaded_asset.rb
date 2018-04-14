require 'sprockets/uri_utils'
require 'sprockets/uri_tar'

module Sprockets
  # Internal: Used to parse and store the URI to an unloaded asset
  # Generates keys used to store and retrieve items from cache
  class UnloadedAsset

    # Internal: Initialize object for generating cache keys
    #
    # uri - A String containing complete URI to a file including scheme
    #       and full path such as
    #       "file:///Path/app/assets/js/app.js?type=application/javascript"
    # env - The current "environment" that assets are being loaded into.
    #       We need it so we know where the +root+ (directory where sprockets
    #       is being invoked). We also need for the `file_digest` method,
    #       since, for some strange reason, memoization is provided by
    #       overriding methods such as `stat` in the `PathUtils` module.
    #
    # Returns UnloadedAsset.
    def initialize(uri, env)
      @uri               = uri.to_s
      @env               = env
      @compressed_path   = URITar.new(uri, env).compressed_path
      @params            = nil # lazy loaded
      @filename          = nil # lazy loaded
    end
    attr_reader :compressed_path, :uri

    # Internal: Full file path without schema
    #
    # This returns a string containing the full path to the asset without the schema.
    # Information is loaded lazilly since we want `UnloadedAsset.new(dep, self).relative_path`
    # to be fast. Calling this method the first time allocates an array and a hash.
    #
    # Example
    #
    # If the URI is `file:///Full/path/app/assets/javascripts/application.js"` then the
    # filename would be `"/Full/path/app/assets/javascripts/application.js"`
    #
    # Returns a String.
    def filename
      unless @filename
        load_file_params
      end
      @filename
    end

    # Internal: Hash of param values
    #
    # This information is generated and used internally by sprockets.
    # Known keys include `:type` which store the asset's mime-type, `:id` which is a fully resolved
    # digest for the asset (includes dependency digest as opposed to a digest of only file contents)
    # and `:pipeline`. Hash may be empty.
    #
    # Example
    #
    # If the URI is `file:///Full/path/app/assets/javascripts/application.js"type=application/javascript`
    # Then the params would be `{type: "application/javascript"}`
    #
    # Returns a Hash.
    def params
      unless @params
        load_file_params
      end
      @params
    end

    # Internal: Key of asset
    #
    # Used to retrieve an asset from the cache based on "compressed" path to asset.
    # A "compressed" path can either be relative to the root of the project or an
    # absolute path.
    #
    # Returns a String.
    def asset_key
      "asset-uri:#{compressed_path}"
    end

    # Public: Dependency History key
    #
    # Used to retrieve an array of "histories" each of which contain a set of stored dependencies
    # for a given asset path and filename digest.
    #
    # A dependency can refer to either an asset i.e. index.js
    # may rely on jquery.js (so jquery.js is a dependency), or other factors that may affect
    # compilation, such as the VERSION of sprockets (i.e. the environment) and what "processors"
    # are used.
    #
    # For example a history array with one Set of dependencies may look like:
    #
    # [["environment-version", "environment-paths", "processors:type=text/css&file_type=text/css",
    #   "file-digest:///Full/path/app/assets/stylesheets/application.css",
    #   "processors:type=text/css&file_type=text/css&pipeline=self",
    #   "file-digest:///Full/path/app/assets/stylesheets"]]
    #
    # This method of asset lookup is used to ensure that none of the dependencies have been modified
    # since last lookup. If one of them has, the key will be different and a new entry must be stored.
    #
    # URI depndencies are later converted to "compressed" paths
    #
    # Returns a String.
    def dependency_history_key
      "asset-uri-cache-dependencies:#{compressed_path}:#{ @env.file_digest(filename) }"
    end

    # Internal: Digest key
    #
    # Used to retrieve a string containing the "compressed" path to an asset based on
    # a digest. The digest is generated from dependencies stored via information stored in
    # the `dependency_history_key` after each of the "dependencies" is "resolved" for example
    # "environment-version" may be resolved to "environment-1.0-3.2.0" for version "3.2.0" of sprockets
    #
    # Returns a String.
    def digest_key(digest)
      "asset-uri-digest:#{compressed_path}:#{digest}"
    end

    # Internal: File digest key
    #
    # The digest for a given file won't change if the path and the stat time hasn't changed
    # We can save time by not re-computing this information and storing it in the cache
    #
    # Returns a String.
    def file_digest_key(stat)
      "file_digest:#{compressed_path}:#{stat}"
    end

    private
      # Internal: Parses uri into filename and params hash
      #
      # Returns Array with filename and params hash
      def load_file_params
        @filename, @params = URIUtils.parse_asset_uri(uri)
      end
  end
end
