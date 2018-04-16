# -*- ruby encoding: utf-8 -*-

##
module MIME; end
##
class MIME::Types; end

require 'mime/types/data'

# This class is responsible for initializing the MIME::Types registry from
# the data files supplied with the mime-types library.
#
# The Loader will use one of the following paths:
# 1.  The +path+ provided in its constructor argument;
# 2.  The value of ENV['RUBY_MIME_TYPES_DATA']; or
# 3.  The value of MIME::Types::Data::PATH.
#
# When #load is called, the +path+ will be searched recursively for all YAML
# (.yml or .yaml) files. By convention, there is one file for each media
# type (application.yml, audio.yml, etc.), but this is not required.
class MIME::Types::Loader
  # The path that will be read for the MIME::Types files.
  attr_reader :path
  # The MIME::Types container instance that will be loaded. If not provided
  # at initialization, a new MIME::Types instance will be constructed.
  attr_reader :container

  # Creates a Loader object that can be used to load MIME::Types registries
  # into memory, using YAML, JSON, or Columnar registry format loaders.
  def initialize(path = nil, container = nil)
    path = path || ENV['RUBY_MIME_TYPES_DATA'] || MIME::Types::Data::PATH
    @container = container || MIME::Types.new
    @path = File.expand_path(path)
    # begin
    #   require 'mime/lazy_types'
    #   @container.extend(MIME::LazyTypes)
    # end
  end

  # Loads a MIME::Types registry from YAML files (<tt>*.yml</tt> or
  # <tt>*.yaml</tt>) recursively found in +path+.
  #
  # It is expected that the YAML objects contained within the registry array
  # will be tagged as <tt>!ruby/object:MIME::Type</tt>.
  #
  # Note that the YAML format is about 2½ times *slower* than the JSON format.
  #
  # NOTE: The purpose of this format is purely for maintenance reasons.
  def load_yaml
    Dir[yaml_path].sort.each do |f|
      container.add(*self.class.load_from_yaml(f), :silent)
    end
    container
  end

  # Loads a MIME::Types registry from JSON files (<tt>*.json</tt>)
  # recursively found in +path+.
  #
  # It is expected that the JSON objects will be an array of hash objects.
  # The JSON format is the registry format for the MIME types registry
  # shipped with the mime-types library.
  def load_json
    Dir[json_path].sort.each do |f|
      types = self.class.load_from_json(f)
      container.add(*types, :silent)
    end
    container
  end

  # Loads a MIME::Types registry from columnar files recursively found in
  # +path+.
  def load_columnar
    require 'mime/types/columnar' unless defined?(MIME::Types::Columnar)
    container.extend(MIME::Types::Columnar)
    container.load_base_data(path)

    container
  end

  # Loads a MIME::Types registry. Loads from JSON files by default
  # (#load_json).
  #
  # This will load from columnar files (#load_columnar) if <tt>columnar:
  # true</tt> is provided in +options+ and there are columnar files in +path+.
  def load(options = { columnar: false })
    if options[:columnar] && !Dir[columnar_path].empty?
      load_columnar
    else
      load_json
    end
  end

  class << self
    # Loads the default MIME::Type registry.
    def load(options = { columnar: false })
      new.load(options)
    end

    # Loads MIME::Types from a single YAML file.
    #
    # It is expected that the YAML objects contained within the registry
    # array will be tagged as <tt>!ruby/object:MIME::Type</tt>.
    #
    # Note that the YAML format is about 2½ times *slower* than the JSON
    # format.
    #
    # NOTE: The purpose of this format is purely for maintenance reasons.
    def load_from_yaml(filename)
      begin
        require 'psych'
      rescue LoadError
        nil
      end
      require 'yaml'
      YAML.load(read_file(filename))
    end

    # Loads MIME::Types from a single JSON file.
    #
    # It is expected that the JSON objects will be an array of hash objects.
    # The JSON format is the registry format for the MIME types registry
    # shipped with the mime-types library.
    def load_from_json(filename)
      require 'json'
      JSON.parse(read_file(filename)).map { |type| MIME::Type.new(type) }
    end

    private

    def read_file(filename)
      File.open(filename, 'r:UTF-8:-', &:read)
    end
  end

  private

  def yaml_path
    File.join(path, '*.y{,a}ml')
  end

  def json_path
    File.join(path, '*.json')
  end

  def columnar_path
    File.join(path, '*.column')
  end
end
