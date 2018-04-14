module HttpAcceptLanguage
  class Parser
    attr_accessor :header

    def initialize(header)
      @header = header
    end

    # Returns a sorted array based on user preference in HTTP_ACCEPT_LANGUAGE.
    # Browsers send this HTTP header, so don't think this is holy.
    #
    # Example:
    #
    #   request.user_preferred_languages
    #   # => [ 'nl-NL', 'nl-BE', 'nl', 'en-US', 'en' ]
    #
    def user_preferred_languages
      @user_preferred_languages ||= begin
        header.to_s.gsub(/\s+/, '').split(',').map do |language|
          locale, quality = language.split(';q=')
          raise ArgumentError, 'Not correctly formatted' unless locale =~ /^[a-z\-0-9]+|\*$/i

          locale  = locale.downcase.gsub(/-[a-z0-9]+$/i, &:upcase) # Uppercase territory
          locale  = nil if locale == '*' # Ignore wildcards

          quality = quality ? quality.to_f : 1.0

          [locale, quality]
        end.sort do |(_, left), (_, right)|
          right <=> left
        end.map(&:first).compact
      rescue ArgumentError # Just rescue anything if the browser messed up badly.
        []
      end
    end

    # Sets the user languages preference, overriding the browser
    #
    def user_preferred_languages=(languages)
      @user_preferred_languages = languages
    end

    # Finds the locale specifically requested by the browser.
    #
    # Example:
    #
    #   request.preferred_language_from I18n.available_locales
    #   # => 'nl'
    #
    def preferred_language_from(array)
      (user_preferred_languages & array.map(&:to_s)).first
    end

    # Returns the first of the user_preferred_languages that is compatible
    # with the available locales. Ignores region.
    #
    # Example:
    #
    #   request.compatible_language_from I18n.available_locales
    #
    def compatible_language_from(available_languages)
      user_preferred_languages.map do |preferred| #en-US
        preferred = preferred.downcase
        preferred_language = preferred.split('-', 2).first

        available_languages.find do |available| # en
          available = available.to_s.downcase
          preferred == available || preferred_language == available.split('-', 2).first
        end
      end.compact.first
    end

    # Returns a supplied list of available locals without any extra application info
    # that may be attached to the locale for storage in the application.
    #
    # Example:
    # [ja_JP-x1, en-US-x4, en_UK-x5, fr-FR-x3] => [ja-JP, en-US, en-UK, fr-FR]
    #
    def sanitize_available_locales(available_languages)
      available_languages.map do |available|
        available.to_s.split(/[_-]/).reject { |part| part.start_with?("x") }.join("-")
      end
    end

    # Returns the first of the user preferred languages that is
    # also found in available languages.  Finds best fit by matching on
    # primary language first and secondarily on region.  If no matching region is
    # found, return the first language in the group matching that primary language.
    #
    # Example:
    #
    #   request.language_region_compatible(available_languages)
    #
    def language_region_compatible_from(available_languages)
      available_languages = sanitize_available_locales(available_languages)
      user_preferred_languages.map do |preferred| #en-US
        preferred = preferred.downcase
        preferred_language = preferred.split('-', 2).first

        lang_group = available_languages.select do |available| # en
          preferred_language == available.downcase.split('-', 2).first
        end
        
        lang_group.find { |lang| lang.downcase == preferred } || lang_group.first #en-US, en-UK
      end.compact.first
    end
  end
end
