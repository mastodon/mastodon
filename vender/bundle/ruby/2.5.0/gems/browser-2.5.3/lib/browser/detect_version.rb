# frozen_string_literal: true

module Browser
  module DetectVersion
    private

    def detect_version?(actual_version, expected_version)
      return true unless expected_version
      return false if expected_version && !actual_version

      expected_version = parse_version(expected_version)
      actual_version = parse_version(actual_version)

      Gem::Requirement.create(expected_version)
                      .satisfied_by?(Gem::Version.create(actual_version))
    end

    def parse_version(version)
      version.kind_of?(Numeric) ? version.to_s : version
    end
  end
end
