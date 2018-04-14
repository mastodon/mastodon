require 'sprockets/utils'

module Sprockets
  # `Compressing` is an internal mixin whose public methods are exposed on
  # the `Environment` and `CachedEnvironment` classes.
  module Compressing
    include Utils

    def compressors
      config[:compressors]
    end

    def register_compressor(mime_type, sym, klass)
      self.config = hash_reassoc(config, :compressors, mime_type) do |compressors|
        compressors[sym] = klass
        compressors
      end
    end

    # Return CSS compressor or nil if none is set
    def css_compressor
      if defined? @css_compressor
        @css_compressor
      end
    end

    # Assign a compressor to run on `text/css` assets.
    #
    # The compressor object must respond to `compress`.
    def css_compressor=(compressor)
      unregister_bundle_processor 'text/css', @css_compressor if defined? @css_compressor
      @css_compressor = nil
      return unless compressor

      if compressor.is_a?(Symbol)
        @css_compressor = klass = config[:compressors]['text/css'][compressor] || raise(Error, "unknown compressor: #{compressor}")
      elsif compressor.respond_to?(:compress)
        klass = LegacyProcProcessor.new(:css_compressor, proc { |context, data| compressor.compress(data) })
        @css_compressor = :css_compressor
      else
        @css_compressor = klass = compressor
      end

      register_bundle_processor 'text/css', klass
    end

    # Return JS compressor or nil if none is set
    def js_compressor
      if defined? @js_compressor
        @js_compressor
      end
    end

    # Assign a compressor to run on `application/javascript` assets.
    #
    # The compressor object must respond to `compress`.
    def js_compressor=(compressor)
      unregister_bundle_processor 'application/javascript', @js_compressor if defined? @js_compressor
      @js_compressor = nil
      return unless compressor

      if compressor.is_a?(Symbol)
        @js_compressor = klass = config[:compressors]['application/javascript'][compressor] || raise(Error, "unknown compressor: #{compressor}")
      elsif compressor.respond_to?(:compress)
        klass = LegacyProcProcessor.new(:js_compressor, proc { |context, data| compressor.compress(data) })
        @js_compressor = :js_compressor
      else
        @js_compressor = klass = compressor
      end

      register_bundle_processor 'application/javascript', klass
    end

    # Public: Checks if Gzip is enabled.
    def gzip?
      config[:gzip_enabled]
    end

    # Public: Checks if Gzip is disabled.
    def skip_gzip?
      !gzip?
    end

    # Public: Enable or disable the creation of Gzip files.
    #
    # Defaults to true.
    #
    #     environment.gzip = false
    #
    def gzip=(gzip)
      self.config = config.merge(gzip_enabled: gzip).freeze
    end
  end
end
