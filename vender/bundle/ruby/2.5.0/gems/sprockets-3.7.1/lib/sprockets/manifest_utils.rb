require 'securerandom'

module Sprockets
  # Public: Manifest utilities.
  module ManifestUtils
    extend self

    MANIFEST_RE = /^\.sprockets-manifest-[0-9a-f]{32}.json$/
    LEGACY_MANIFEST_RE = /^manifest(-[0-9a-f]{32})?.json$/

    # Public: Generate a new random manifest path.
    #
    # Manifests are not intended to be accessed publicly, but typically live
    # alongside public assets for convenience. To avoid being served, the
    # filename is prefixed with a "." which is usually hidden by web servers
    # like Apache. To help in other environments that may not control this,
    # a random hex string is appended to the filename to prevent people from
    # guessing the location. If directory indexes are enabled on the server,
    # all bets are off.
    #
    # Return String path.
    def generate_manifest_path
      ".sprockets-manifest-#{SecureRandom.hex(16)}.json"
    end

    # Public: Find or pick a new manifest filename for target build directory.
    #
    # dirname - String dirname
    #
    # Examples
    #
    #     find_directory_manifest("/app/public/assets")
    #     # => "/app/public/assets/.sprockets-manifest-abc123.json"
    #
    # Returns String filename.
    def find_directory_manifest(dirname)
      entries = File.directory?(dirname) ? Dir.entries(dirname) : []
      entry = entries.find { |e| e =~ MANIFEST_RE } ||
        # Deprecated: Will be removed in 4.x
        entries.find { |e| e =~ LEGACY_MANIFEST_RE } ||
        generate_manifest_path
      File.join(dirname, entry)
    end
  end
end
