module Bootsnap
  module ExplicitRequire
    ARCHDIR    = RbConfig::CONFIG['archdir']
    RUBYLIBDIR = RbConfig::CONFIG['rubylibdir']
    DLEXT      = RbConfig::CONFIG['DLEXT']

    def self.from_self(feature)
      require_relative "../#{feature}"
    end

    def self.from_rubylibdir(feature)
      require(File.join(RUBYLIBDIR, "#{feature}.rb"))
    end

    def self.from_archdir(feature)
      require(File.join(ARCHDIR, "#{feature}.#{DLEXT}"))
    end

    # Given a set of gems, run a block with the LOAD_PATH narrowed to include
    # only core ruby source paths and these gems -- that is, roughly,
    # temporarily remove all gems not listed in this call from the LOAD_PATH.
    #
    # This is useful before bootsnap is fully-initialized to load gems that it
    # depends on, without forcing full LOAD_PATH traversals.
    def self.with_gems(*gems)
      orig = $LOAD_PATH.dup
      $LOAD_PATH.clear
      gems.each do |gem|
        pat = %r{
          /
          (gems|extensions/[^/]+/[^/]+)          # "gems" or "extensions/x64_64-darwin16/2.3.0"
          /
          #{Regexp.escape(gem)}-(\h{12}|(\d+\.)) # msgpack-1.2.3 or msgpack-1234567890ab
        }x
        $LOAD_PATH.concat(orig.grep(pat))
      end
      $LOAD_PATH << ARCHDIR
      $LOAD_PATH << RUBYLIBDIR
      begin
        yield
      rescue LoadError
        $LOAD_PATH.replace(orig)
        yield
      end
    ensure
      $LOAD_PATH.replace(orig)
    end
  end
end
