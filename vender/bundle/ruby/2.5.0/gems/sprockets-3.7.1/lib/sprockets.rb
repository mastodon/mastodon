# encoding: utf-8
require 'sprockets/version'
require 'sprockets/cache'
require 'sprockets/environment'
require 'sprockets/errors'
require 'sprockets/manifest'
require 'sprockets/deprecation'

module Sprockets
  require 'sprockets/processor_utils'
  extend ProcessorUtils

  # Extend Sprockets module to provide global registry
  require 'sprockets/configuration'
  require 'sprockets/context'
  require 'digest/sha2'
  extend Configuration

  self.config = {
    bundle_processors: Hash.new { |h, k| [].freeze }.freeze,
    bundle_reducers: Hash.new { |h, k| {}.freeze }.freeze,
    compressors: Hash.new { |h, k| {}.freeze }.freeze,
    dependencies: Set.new.freeze,
    dependency_resolvers: {}.freeze,
    digest_class: Digest::SHA256,
    engine_mime_types: {}.freeze,
    engines: {}.freeze,
    mime_exts: {}.freeze,
    mime_types: {}.freeze,
    paths: [].freeze,
    pipelines: {}.freeze,
    postprocessors: Hash.new { |h, k| [].freeze }.freeze,
    preprocessors: Hash.new { |h, k| [].freeze }.freeze,
    registered_transformers: Hash.new { |h, k| {}.freeze }.freeze,
    root: File.expand_path('..', __FILE__).freeze,
    transformers: Hash.new { |h, k| {}.freeze }.freeze,
    version: "",
    gzip_enabled: true
  }.freeze
  self.computed_config = {}

  @context_class = Context

  require 'logger'
  @logger = Logger.new($stderr)
  @logger.level = Logger::FATAL

  # Common asset text types
  register_mime_type 'application/javascript', extensions: ['.js'], charset: :unicode
  register_mime_type 'application/json', extensions: ['.json'], charset: :unicode
  register_mime_type 'application/xml', extensions: ['.xml']
  register_mime_type 'text/css', extensions: ['.css'], charset: :css
  register_mime_type 'text/html', extensions: ['.html', '.htm'], charset: :html
  register_mime_type 'text/plain', extensions: ['.txt', '.text']
  register_mime_type 'text/yaml', extensions: ['.yml', '.yaml'], charset: :unicode

  # Common image types
  register_mime_type 'image/x-icon', extensions: ['.ico']
  register_mime_type 'image/bmp', extensions: ['.bmp']
  register_mime_type 'image/gif', extensions: ['.gif']
  register_mime_type 'image/webp', extensions: ['.webp']
  register_mime_type 'image/png', extensions: ['.png']
  register_mime_type 'image/jpeg', extensions: ['.jpg', '.jpeg']
  register_mime_type 'image/tiff', extensions: ['.tiff', '.tif']
  register_mime_type 'image/svg+xml', extensions: ['.svg']

  # Common audio/video types
  register_mime_type 'video/webm', extensions: ['.webm']
  register_mime_type 'audio/basic', extensions: ['.snd', '.au']
  register_mime_type 'audio/aiff', extensions: ['.aiff']
  register_mime_type 'audio/mpeg', extensions: ['.mp3', '.mp2', '.m2a', '.m3a']
  register_mime_type 'application/ogg', extensions: ['.ogx']
  register_mime_type 'audio/midi', extensions: ['.midi', '.mid']
  register_mime_type 'video/avi', extensions: ['.avi']
  register_mime_type 'audio/wave', extensions: ['.wav', '.wave']
  register_mime_type 'video/mp4', extensions: ['.mp4', '.m4v']

  # Common font types
  register_mime_type 'application/vnd.ms-fontobject', extensions: ['.eot']
  register_mime_type 'application/x-font-opentype', extensions: ['.otf']
  register_mime_type 'application/x-font-ttf', extensions: ['.ttf']
  register_mime_type 'application/font-woff', extensions: ['.woff']

  register_pipeline :source do |env|
    []
  end

  register_pipeline :self do |env, type, file_type, engine_extnames|
    env.self_processors_for(type, file_type, engine_extnames)
  end

  register_pipeline :default do |env, type, file_type, engine_extnames|
    env.default_processors_for(type, file_type, engine_extnames)
  end

  require 'sprockets/directive_processor'
  register_preprocessor 'text/css', DirectiveProcessor.new(
    comments: ["//", ["/*", "*/"]]
  )
  register_preprocessor 'application/javascript', DirectiveProcessor.new(
    comments: ["//", ["/*", "*/"]] + ["#", ["###", "###"]]
  )

  require 'sprockets/bundle'
  register_bundle_processor 'application/javascript', Bundle
  register_bundle_processor 'text/css', Bundle

  register_bundle_metadata_reducer '*/*', :data, proc { "" }, :concat
  register_bundle_metadata_reducer 'application/javascript', :data, proc { "" }, Utils.method(:concat_javascript_sources)
  register_bundle_metadata_reducer '*/*', :links, :+

  require 'sprockets/closure_compressor'
  require 'sprockets/sass_compressor'
  require 'sprockets/uglifier_compressor'
  require 'sprockets/yui_compressor'
  register_compressor 'text/css', :sass, SassCompressor
  register_compressor 'text/css', :scss, SassCompressor
  register_compressor 'text/css', :yui, YUICompressor
  register_compressor 'application/javascript', :closure, ClosureCompressor
  register_compressor 'application/javascript', :uglifier, UglifierCompressor
  register_compressor 'application/javascript', :uglify, UglifierCompressor
  register_compressor 'application/javascript', :yui, YUICompressor

  # Mmm, CoffeeScript
  require 'sprockets/coffee_script_processor'
  Deprecation.silence do
    register_engine '.coffee', CoffeeScriptProcessor, mime_type: 'application/javascript', silence_deprecation: true
  end

  # JST engines
  require 'sprockets/eco_processor'
  require 'sprockets/ejs_processor'
  require 'sprockets/jst_processor'
  Deprecation.silence do
    register_engine '.jst', JstProcessor, mime_type: 'application/javascript', silence_deprecation: true
    register_engine '.eco', EcoProcessor, mime_type: 'application/javascript', silence_deprecation: true
    register_engine '.ejs', EjsProcessor, mime_type: 'application/javascript', silence_deprecation: true
  end

  # CSS engines
  require 'sprockets/sass_processor'
  Deprecation.silence do
    register_engine '.sass', SassProcessor, mime_type: 'text/css', silence_deprecation: true
    register_engine '.scss', ScssProcessor, mime_type: 'text/css', silence_deprecation: true
  end
  register_bundle_metadata_reducer 'text/css', :sass_dependencies, Set.new, :+

  # Other
  require 'sprockets/erb_processor'
  register_engine '.erb', ERBProcessor, mime_type: 'text/plain', silence_deprecation: true

  register_dependency_resolver 'environment-version' do |env|
    env.version
  end
  register_dependency_resolver 'environment-paths' do |env|
    env.paths.map {|path| env.compress_from_root(path) }
  end
  register_dependency_resolver 'file-digest' do |env, str|
    env.file_digest(env.parse_file_digest_uri(str))
  end
  register_dependency_resolver 'processors' do |env, str|
    env.resolve_processors_cache_key_uri(str)
  end

  depend_on 'environment-version'
  depend_on 'environment-paths'
end

require 'sprockets/legacy'
