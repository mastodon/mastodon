# frozen_string_literal: true

module Browser
  class InternetExplorer < Base
    # https://msdn.microsoft.com/en-us/library/ms537503(v=vs.85).aspx#TriToken
    TRIDENT_MAPPING = {
      "4.0" => "8",
      "5.0" => "9",
      "6.0" => "10",
      "7.0" => "11",
      "8.0" => "12"
    }.freeze

    def id
      :ie
    end

    def name
      "Internet Explorer"
    end

    def full_version
      "#{ie_version}.0"
    end

    def msie_full_version
      (ua.match(%r{MSIE ([\d.]+)|Trident/.*?; rv:([\d.]+)}) && ($1 || $2)) ||
        "0.0"
    end

    def msie_version
      msie_full_version.split(".").first
    end

    def match?
      msie? || modern_ie?
    end

    # Detect if IE is running in compatibility mode.
    def compatibility_view?
      trident_version && msie_version.to_i < (trident_version.to_i + 4)
    end

    private

    def ie_version
      TRIDENT_MAPPING[trident_version] || msie_version
    end

    # Return the trident version.
    def trident_version
      ua.match(%r[Trident/([0-9.]+)]) && $1
    end

    def msie?
      ua =~ /MSIE/ && ua !~ /Opera/
    end

    def modern_ie?
      ua =~ %r[Trident/.*?; rv:(.*?)]
    end
  end
end
