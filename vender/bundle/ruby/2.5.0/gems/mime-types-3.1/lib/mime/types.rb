##
module MIME
  ##
  class Types
  end
end

require 'mime/type'

# MIME::Types is a registry of MIME types. It is both a class (created with
# MIME::Types.new) and a default registry (loaded automatically or through
# interactions with MIME::Types.[] and MIME::Types.type_for).
#
# == The Default mime-types Registry
#
# The default mime-types registry is loaded automatically when the library
# is required (<tt>require 'mime/types'</tt>), but it may be lazily loaded
# (loaded on first use) with the use of the environment variable
# +RUBY_MIME_TYPES_LAZY_LOAD+ having any value other than +false+. The
# initial startup is about 14× faster (~10 ms vs ~140 ms), but the
# registry will be loaded at some point in the future.
#
# The default mime-types registry can also be loaded from a Marshal cache
# file specific to the version of MIME::Types being loaded. This will be
# handled automatically with the use of a file referred to in the
# environment variable +RUBY_MIME_TYPES_CACHE+. MIME::Types will attempt to
# load the registry from this cache file (MIME::Type::Cache.load); if it
# cannot be loaded (because the file does not exist, there is an error, or
# the data is for a different version of mime-types), the default registry
# will be loaded from the normal JSON version and then the cache file will
# be *written* to the location indicated by +RUBY_MIME_TYPES_CACHE+. Cache
# file loads just over 4½× faster (~30 ms vs ~140 ms).
# loads.
#
# Notes:
# * The loading of the default registry is *not* atomic; when using a
#   multi-threaded environment, it is recommended that lazy loading is not
#   used and mime-types is loaded as early as possible.
# * Cache files should be specified per application in a multiprocess
#   environment and should be initialized during deployment or before
#   forking to minimize the chance that the multiple processes will be
#   trying to write to the same cache file at the same time, or that two
#   applications that are on different versions of mime-types would be
#   thrashing the cache.
# * Unless cache files are preinitialized, the application using the
#   mime-types cache file must have read/write permission to the cache file.
#
# == Usage
#  require 'mime/types'
#
#  plaintext = MIME::Types['text/plain']
#  print plaintext.media_type           # => 'text'
#  print plaintext.sub_type             # => 'plain'
#
#  puts plaintext.extensions.join(" ")  # => 'asc txt c cc h hh cpp'
#
#  puts plaintext.encoding              # => 8bit
#  puts plaintext.binary?               # => false
#  puts plaintext.ascii?                # => true
#  puts plaintext.obsolete?             # => false
#  puts plaintext.registered?           # => true
#  puts plaintext == 'text/plain'       # => true
#  puts MIME::Type.simplified('x-appl/x-zip') # => 'appl/zip'
#
class MIME::Types
  # The release version of Ruby MIME::Types
  VERSION = MIME::Type::VERSION

  include Enumerable

  # Creates a new MIME::Types registry.
  def initialize
    @type_variants    = Container.new
    @extension_index  = Container.new
  end

  # Returns the number of known type variants.
  def count
    @type_variants.values.inject(0) { |a, e| a + e.size }
  end

  def inspect # :nodoc:
    "#<#{self.class}: #{count} variants, #{@extension_index.count} extensions>"
  end

  # Iterates through the type variants.
  def each
    if block_given?
      @type_variants.each_value { |tv| tv.each { |t| yield t } }
    else
      enum_for(:each)
    end
  end

  @__types__ = nil

  # Returns a list of MIME::Type objects, which may be empty. The optional
  # flag parameters are <tt>:complete</tt> (finds only complete MIME::Type
  # objects) and <tt>:registered</tt> (finds only MIME::Types that are
  # registered). It is possible for multiple matches to be returned for
  # either type (in the example below, 'text/plain' returns two values --
  # one for the general case, and one for VMS systems).
  #
  #   puts "\nMIME::Types['text/plain']"
  #   MIME::Types['text/plain'].each { |t| puts t.to_a.join(", ") }
  #
  #   puts "\nMIME::Types[/^image/, complete: true]"
  #   MIME::Types[/^image/, :complete => true].each do |t|
  #     puts t.to_a.join(", ")
  #   end
  #
  # If multiple type definitions are returned, returns them sorted as
  # follows:
  #   1. Complete definitions sort before incomplete ones;
  #   2. IANA-registered definitions sort before LTSW-recorded
  #      definitions.
  #   3. Current definitions sort before obsolete ones;
  #   4. Obsolete definitions with use-instead clauses sort before those
  #      without;
  #   5. Obsolete definitions use-instead clauses are compared.
  #   6. Sort on name.
  def [](type_id, complete: false, registered: false)
    matches = case type_id
              when MIME::Type
                @type_variants[type_id.simplified]
              when Regexp
                match(type_id)
              else
                @type_variants[MIME::Type.simplified(type_id)]
              end

    prune_matches(matches, complete, registered).sort { |a, b|
      a.priority_compare(b)
    }
  end

  # Return the list of MIME::Types which belongs to the file based on its
  # filename extension. If there is no extension, the filename will be used
  # as the matching criteria on its own.
  #
  # This will always return a merged, flatten, priority sorted, unique array.
  #
  #   puts MIME::Types.type_for('citydesk.xml')
  #     => [application/xml, text/xml]
  #   puts MIME::Types.type_for('citydesk.gif')
  #     => [image/gif]
  #   puts MIME::Types.type_for(%w(citydesk.xml citydesk.gif))
  #     => [application/xml, image/gif, text/xml]
  def type_for(filename)
    Array(filename).flat_map { |fn|
      @extension_index[fn.chomp.downcase[/\.?([^.]*?)$/, 1]]
    }.compact.inject(:+).sort { |a, b|
      a.priority_compare(b)
    }
  end
  alias_method :of, :type_for

  # Add one or more MIME::Type objects to the set of known types. If the
  # type is already known, a warning will be displayed.
  #
  # The last parameter may be the value <tt>:silent</tt> or +true+ which
  # will suppress duplicate MIME type warnings.
  def add(*types)
    quiet = ((types.last == :silent) or (types.last == true))

    types.each do |mime_type|
      case mime_type
      when true, false, nil, Symbol
        nil
      when MIME::Types
        variants = mime_type.instance_variable_get(:@type_variants)
        add(*variants.values.inject(:+).to_a, quiet)
      when Array
        add(*mime_type, quiet)
      else
        add_type(mime_type, quiet)
      end
    end
  end

  # Add a single MIME::Type object to the set of known types. If the +type+ is
  # already known, a warning will be displayed. The +quiet+ parameter may be a
  # truthy value to suppress that warning.
  def add_type(type, quiet = false)
    if !quiet and @type_variants[type.simplified].include?(type)
      MIME::Types.logger.warn <<-warning
Type #{type} is already registered as a variant of #{type.simplified}.
      warning
    end

    add_type_variant!(type)
    index_extensions!(type)
  end

  private

  def add_type_variant!(mime_type)
    @type_variants[mime_type.simplified] << mime_type
  end

  def reindex_extensions!(mime_type)
    return unless @type_variants[mime_type.simplified].include?(mime_type)
    index_extensions!(mime_type)
  end

  def index_extensions!(mime_type)
    mime_type.extensions.each { |ext| @extension_index[ext] << mime_type }
  end

  def prune_matches(matches, complete, registered)
    matches.delete_if { |e| !e.complete? } if complete
    matches.delete_if { |e| !e.registered? } if registered
    matches
  end

  def match(pattern)
    @type_variants.select { |k, _|
      k =~ pattern
    }.values.inject(:+)
  end
end

require 'mime/types/cache'
require 'mime/types/container'
require 'mime/types/loader'
require 'mime/types/logger'
require 'mime/types/_columnar'
require 'mime/types/registry'
