require 'sprockets/asset'
require 'sprockets/digest_utils'
require 'sprockets/engines'
require 'sprockets/errors'
require 'sprockets/file_reader'
require 'sprockets/mime'
require 'sprockets/path_utils'
require 'sprockets/processing'
require 'sprockets/processor_utils'
require 'sprockets/resolve'
require 'sprockets/transformers'
require 'sprockets/uri_utils'
require 'sprockets/unloaded_asset'

module Sprockets

  # The loader phase takes a asset URI location and returns a constructed Asset
  # object.
  module Loader
    include DigestUtils, PathUtils, ProcessorUtils, URIUtils
    include Engines, Mime, Processing, Resolve, Transformers


    # Public: Load Asset by Asset URI.
    #
    # uri - A String containing complete URI to a file including schema
    #       and full path such as:
    #       "file:///Path/app/assets/js/app.js?type=application/javascript"
    #
    #
    # Returns Asset.
    def load(uri)
      unloaded = UnloadedAsset.new(uri, self)
      if unloaded.params.key?(:id)
        unless asset = asset_from_cache(unloaded.asset_key)
          id = unloaded.params.delete(:id)
          uri_without_id = build_asset_uri(unloaded.filename, unloaded.params)
          asset = load_from_unloaded(UnloadedAsset.new(uri_without_id, self))
          if asset[:id] != id
            @logger.warn "Sprockets load error: Tried to find #{uri}, but latest was id #{asset[:id]}"
          end
        end
      else
        asset = fetch_asset_from_dependency_cache(unloaded) do |paths|
          # When asset is previously generated, its "dependencies" are stored in the cache.
          # The presence of `paths` indicates dependencies were stored.
          # We can check to see if the dependencies have not changed by "resolving" them and
          # generating a digest key from the resolved entries. If this digest key has not
          # changed the asset will be pulled from cache.
          #
          # If this `paths` is present but the cache returns nothing then `fetch_asset_from_dependency_cache`
          # will confusingly be called again with `paths` set to nil where the asset will be
          # loaded from disk.
          if paths
            digest = DigestUtils.digest(resolve_dependencies(paths))
            if uri_from_cache = cache.get(unloaded.digest_key(digest), true)
              asset_from_cache(UnloadedAsset.new(uri_from_cache, self).asset_key)
            end
          else
            load_from_unloaded(unloaded)
          end
        end
      end
      Asset.new(self, asset)
    end

    private

      # Internal: Load asset hash from cache
      #
      # key - A String containing lookup information for an asset
      #
      # This method converts all "compressed" paths to absolute paths.
      # Returns a hash of values representing an asset
      def asset_from_cache(key)
        asset = cache.get(key, true)
        if asset
          asset[:uri]       = expand_from_root(asset[:uri])
          asset[:load_path] = expand_from_root(asset[:load_path])
          asset[:filename]  = expand_from_root(asset[:filename])
          asset[:metadata][:included].map!          { |uri| expand_from_root(uri) } if asset[:metadata][:included]
          asset[:metadata][:links].map!             { |uri| expand_from_root(uri) } if asset[:metadata][:links]
          asset[:metadata][:stubbed].map!           { |uri| expand_from_root(uri) } if asset[:metadata][:stubbed]
          asset[:metadata][:required].map!          { |uri| expand_from_root(uri) } if asset[:metadata][:required]
          asset[:metadata][:dependencies].map!      { |uri| uri.start_with?("file-digest://") ? expand_from_root(uri) : uri } if asset[:metadata][:dependencies]

          asset[:metadata].each_key do |k|
            next unless k =~ /_dependencies\z/
            asset[:metadata][k].map! { |uri| expand_from_root(uri) }
          end
        end
        asset
      end

      # Internal: Loads an asset and saves it to cache
      #
      # unloaded - An UnloadedAsset
      #
      # This method is only called when the given unloaded asset could not be
      # successfully pulled from cache.
      def load_from_unloaded(unloaded)
        unless file?(unloaded.filename)
          raise FileNotFound, "could not find file: #{unloaded.filename}"
        end

        load_path, logical_path = paths_split(config[:paths], unloaded.filename)

        unless load_path
          raise FileOutsidePaths, "#{unloaded.filename} is no longer under a load path: #{self.paths.join(', ')}"
        end

        logical_path, file_type, engine_extnames, _ = parse_path_extnames(logical_path)
        name = logical_path

        if pipeline = unloaded.params[:pipeline]
          logical_path += ".#{pipeline}"
        end

        if type = unloaded.params[:type]
          logical_path += config[:mime_types][type][:extensions].first
        end

        if type != file_type && !config[:transformers][file_type][type]
          raise ConversionError, "could not convert #{file_type.inspect} to #{type.inspect}"
        end

        processors = processors_for(type, file_type, engine_extnames, pipeline)

        processors_dep_uri = build_processors_uri(type, file_type, engine_extnames, pipeline)
        dependencies = config[:dependencies] + [processors_dep_uri]

        # Read into memory and process if theres a processor pipeline
        if processors.any?
          result = call_processors(processors, {
            environment: self,
            cache: self.cache,
            uri: unloaded.uri,
            filename: unloaded.filename,
            load_path: load_path,
            name: name,
            content_type: type,
            metadata: { dependencies: dependencies }
          })
          validate_processor_result!(result)
          source = result.delete(:data)
          metadata = result
          metadata[:charset] = source.encoding.name.downcase unless metadata.key?(:charset)
          metadata[:digest]  = digest(source)
          metadata[:length]  = source.bytesize
        else
          dependencies << build_file_digest_uri(unloaded.filename)
          metadata = {
            digest: file_digest(unloaded.filename),
            length: self.stat(unloaded.filename).size,
            dependencies: dependencies
          }
        end

        asset = {
          uri: unloaded.uri,
          load_path: load_path,
          filename: unloaded.filename,
          name: name,
          logical_path: logical_path,
          content_type: type,
          source: source,
          metadata: metadata,
          dependencies_digest: DigestUtils.digest(resolve_dependencies(metadata[:dependencies]))
        }

        asset[:id]  = pack_hexdigest(digest(asset))
        asset[:uri] = build_asset_uri(unloaded.filename, unloaded.params.merge(id: asset[:id]))

        # Deprecated: Avoid tracking Asset mtime
        asset[:mtime] = metadata[:dependencies].map { |u|
          if u.start_with?("file-digest:")
            s = self.stat(parse_file_digest_uri(u))
            s ? s.mtime.to_i : nil
          else
            nil
          end
        }.compact.max
        asset[:mtime] ||= self.stat(unloaded.filename).mtime.to_i

        store_asset(asset, unloaded)
        asset
      end

      # Internal: Save a given asset to the cache
      #
      # asset - A hash containing values of loaded asset
      # unloaded - The UnloadedAsset used to lookup the `asset`
      #
      # This method converts all absolute paths to "compressed" paths
      # which are relative if they're in the root.
      def store_asset(asset, unloaded)
        # Save the asset in the cache under the new URI
        cached_asset             = asset.dup
        cached_asset[:uri]       = compress_from_root(asset[:uri])
        cached_asset[:filename]  = compress_from_root(asset[:filename])
        cached_asset[:load_path] = compress_from_root(asset[:load_path])

        if cached_asset[:metadata]
          # Deep dup to avoid modifying `asset`
          cached_asset[:metadata] = cached_asset[:metadata].dup
          if cached_asset[:metadata][:included] && !cached_asset[:metadata][:included].empty?
            cached_asset[:metadata][:included] = cached_asset[:metadata][:included].dup
            cached_asset[:metadata][:included].map! { |uri| compress_from_root(uri) }
          end

          if cached_asset[:metadata][:links] && !cached_asset[:metadata][:links].empty?
            cached_asset[:metadata][:links] = cached_asset[:metadata][:links].dup
            cached_asset[:metadata][:links].map! { |uri| compress_from_root(uri) }
          end

          if cached_asset[:metadata][:stubbed] && !cached_asset[:metadata][:stubbed].empty?
            cached_asset[:metadata][:stubbed] = cached_asset[:metadata][:stubbed].dup
            cached_asset[:metadata][:stubbed].map! { |uri| compress_from_root(uri) }
          end

          if cached_asset[:metadata][:required] && !cached_asset[:metadata][:required].empty?
            cached_asset[:metadata][:required] = cached_asset[:metadata][:required].dup
            cached_asset[:metadata][:required].map! { |uri| compress_from_root(uri) }
          end

          if cached_asset[:metadata][:dependencies] && !cached_asset[:metadata][:dependencies].empty?
            cached_asset[:metadata][:dependencies] = cached_asset[:metadata][:dependencies].dup
            cached_asset[:metadata][:dependencies].map! do |uri|
              uri.start_with?("file-digest://".freeze) ? compress_from_root(uri) : uri
            end
          end

          # compress all _dependencies in metadata like `sass_dependencies`
          cached_asset[:metadata].each do |key, value|
            next unless key =~ /_dependencies\z/
            cached_asset[:metadata][key] = value.dup
            cached_asset[:metadata][key].map! {|uri| compress_from_root(uri) }
          end
        end

        # Unloaded asset and stored_asset now have a different URI
        stored_asset = UnloadedAsset.new(asset[:uri], self)
        cache.set(stored_asset.asset_key, cached_asset, true)

        # Save the new relative path for the digest key of the unloaded asset
        cache.set(unloaded.digest_key(asset[:dependencies_digest]), stored_asset.compressed_path, true)
      end


      # Internal: Resolve set of dependency URIs.
      #
      # uris - An Array of "dependencies" for example:
      #        ["environment-version", "environment-paths", "processors:type=text/css&file_type=text/css",
      #           "file-digest:///Full/path/app/assets/stylesheets/application.css",
      #           "processors:type=text/css&file_type=text/css&pipeline=self",
      #           "file-digest:///Full/path/app/assets/stylesheets"]
      #
      # Returns back array of things that the given uri dpends on
      # For example the environment version, if you're using a different version of sprockets
      # then the dependencies should be different, this is used only for generating cache key
      # for example the "environment-version" may be resolved to "environment-1.0-3.2.0" for
      #  version "3.2.0" of sprockets.
      #
      # Any paths that are returned are converted to relative paths
      #
      # Returns array of resolved dependencies
      def resolve_dependencies(uris)
        uris.map { |uri| resolve_dependency(uri) }
      end

      # Internal: Retrieves an asset based on its digest
      #
      # unloaded - An UnloadedAsset
      # limit    - A Fixnum which sets the maximum number of versions of "histories"
      #            stored in the cache
      #
      # This method attempts to retrieve the last `limit` number of histories of an asset
      # from the cache a "history" which is an array of unresolved "dependencies" that the asset needs
      # to compile. In this case A dependency can refer to either an asset i.e. index.js
      # may rely on jquery.js (so jquery.js is a depndency), or other factors that may affect
      # compilation, such as the VERSION of sprockets (i.e. the environment) and what "processors"
      # are used.
      #
      # For example a history array may look something like this
      #
      #   [["environment-version", "environment-paths", "processors:type=text/css&file_type=text/css",
      #     "file-digest:///Full/path/app/assets/stylesheets/application.css",
      #     "processors:type=text/css&file_digesttype=text/css&pipeline=self",
      #     "file-digest:///Full/path/app/assets/stylesheets"]]
      #
      # Where the first entry is a Set of dependencies for last generated version of that asset.
      # Multiple versions are stored since sprockets keeps the last `limit` number of assets
      # generated present in the system.
      #
      # If a "history" of dependencies is present in the cache, each version of "history" will be
      # yielded to the passed block which is responsible for loading the asset. If found, the existing
      # history will be saved with the dependency that found a valid asset moved to the front.
      #
      # If no history is present, or if none of the histories could be resolved to a valid asset then,
      # the block is yielded to and expected to return a valid asset.
      # When this happens the dependencies for the returned asset are added to the "history", and older
      # entries are removed if the "history" is above `limit`.
      def fetch_asset_from_dependency_cache(unloaded, limit = 3)
        key = unloaded.dependency_history_key

        history = cache.get(key) || []
        history.each_with_index do |deps, index|
          expanded_deps = deps.map do |path|
            path.start_with?("file-digest://") ? expand_from_root(path) : path
          end
          if asset = yield(expanded_deps)
            cache.set(key, history.rotate!(index)) if index > 0
            return asset
          end
        end

        asset = yield
        deps  = asset[:metadata][:dependencies].dup.map! do |uri|
          uri.start_with?("file-digest://") ? compress_from_root(uri) : uri
        end
        cache.set(key, history.unshift(deps).take(limit))
        asset
      end
  end
end
