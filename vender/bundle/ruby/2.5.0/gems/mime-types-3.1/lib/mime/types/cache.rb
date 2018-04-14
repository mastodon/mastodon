MIME::Types::Cache = Struct.new(:version, :data) # :nodoc:

# Caching of MIME::Types registries is advisable if you will be loading
# the default registry relatively frequently. With the class methods on
# MIME::Types::Cache, any MIME::Types registry can be marshaled quickly
# and easily.
#
# The cache is invalidated on a per-data-version basis; a cache file for
# version 3.2015.1118 will not be reused with version 3.2015.1201.
class << MIME::Types::Cache
  # Attempts to load the cache from the file provided as a parameter or in
  # the environment variable +RUBY_MIME_TYPES_CACHE+. Returns +nil+ if the
  # file does not exist, if the file cannot be loaded, or if the data in
  # the cache version is different than this version.
  def load(cache_file = nil)
    cache_file ||= ENV['RUBY_MIME_TYPES_CACHE']
    return nil unless cache_file and File.exist?(cache_file)

    cache = Marshal.load(File.binread(cache_file))
    if cache.version == MIME::Types::Data::VERSION
      Marshal.load(cache.data)
    else
      MIME::Types.logger.warn <<-warning.chomp
Could not load MIME::Types cache: invalid version
      warning
      nil
    end
  rescue => e
    MIME::Types.logger.warn <<-warning.chomp
Could not load MIME::Types cache: #{e}
    warning
    return nil
  end

  # Attempts to save the types provided to the cache file provided.
  #
  # If +types+ is not provided or is +nil+, the cache will contain the
  # current MIME::Types default registry.
  #
  # If +cache_file+ is not provided or is +nil+, the cache will be written
  # to the file specified in the environment variable
  # +RUBY_MIME_TYPES_CACHE+. If there is no cache file specified either
  # directly or through the environment, this method will return +nil+
  def save(types = nil, cache_file = nil)
    cache_file ||= ENV['RUBY_MIME_TYPES_CACHE']
    return nil unless cache_file

    types ||= MIME::Types.send(:__types__)

    File.open(cache_file, 'wb') do |f|
      f.write(
        Marshal.dump(new(MIME::Types::Data::VERSION, Marshal.dump(types)))
      )
    end
  end
end
