module Nokogiri
  # The version of Nokogiri you are using
  VERSION = '1.8.2'

  class VersionInfo # :nodoc:
    def jruby?
      ::JRUBY_VERSION if RUBY_PLATFORM == "java"
    end

    def engine
      defined?(RUBY_ENGINE) ? RUBY_ENGINE : 'mri'
    end

    def loaded_parser_version
      LIBXML_PARSER_VERSION.
        scan(/^(\d+)(\d\d)(\d\d)(?!\d)/).first.
        collect(&:to_i).
        join(".")
    end

    def compiled_parser_version
      LIBXML_VERSION
    end

    def libxml2?
      defined?(LIBXML_VERSION)
    end

    def libxml2_using_system?
      ! libxml2_using_packaged?
    end

    def libxml2_using_packaged?
      NOKOGIRI_USE_PACKAGED_LIBRARIES
    end

    def warnings
      return [] unless libxml2?

      if compiled_parser_version != loaded_parser_version
        ["Nokogiri was built against LibXML version #{compiled_parser_version}, but has dynamically loaded #{loaded_parser_version}"]
      else
        []
      end
    end

    def to_hash
      hash_info = {}
      hash_info['warnings']              = []
      hash_info['nokogiri']              = Nokogiri::VERSION
      hash_info['ruby']                  = {}
      hash_info['ruby']['version']       = ::RUBY_VERSION
      hash_info['ruby']['platform']      = ::RUBY_PLATFORM
      hash_info['ruby']['description']   = ::RUBY_DESCRIPTION
      hash_info['ruby']['engine']        = engine
      hash_info['ruby']['jruby']         = jruby? if jruby?

      if libxml2?
        hash_info['libxml']              = {}
        hash_info['libxml']['binding']   = 'extension'
        if libxml2_using_packaged?
          hash_info['libxml']['source']  = "packaged"
          hash_info['libxml']['libxml2_path'] = NOKOGIRI_LIBXML2_PATH
          hash_info['libxml']['libxslt_path'] = NOKOGIRI_LIBXSLT_PATH
          hash_info['libxml']['libxml2_patches'] = NOKOGIRI_LIBXML2_PATCHES
          hash_info['libxml']['libxslt_patches'] = NOKOGIRI_LIBXSLT_PATCHES
        else
          hash_info['libxml']['source']  = "system"
        end
        hash_info['libxml']['compiled']  = compiled_parser_version
        hash_info['libxml']['loaded']    = loaded_parser_version
        hash_info['warnings']            = warnings
      elsif jruby?
        hash_info['xerces']   = Nokogiri::XERCES_VERSION
        hash_info['nekohtml'] = Nokogiri::NEKO_VERSION
      end

      hash_info
    end

    def to_markdown
      begin
        require 'psych'
      rescue LoadError
      end
      require 'yaml'
      "# Nokogiri (#{Nokogiri::VERSION})\n" +
      YAML.dump(to_hash).each_line.map { |line| "    #{line}" }.join
    end

    # FIXME: maybe switch to singleton?
    @@instance = new
    @@instance.warnings.each do |warning|
      warn "WARNING: #{warning}"
    end
    def self.instance; @@instance; end
  end

  # More complete version information about libxml
  VERSION_INFO = VersionInfo.instance.to_hash

  def self.uses_libxml? # :nodoc:
    VersionInfo.instance.libxml2?
  end

  def self.jruby? # :nodoc:
    VersionInfo.instance.jruby?
  end
end
