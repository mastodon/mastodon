module Encryptor
  # Contains information about this gem's version
  module Version
    MAJOR = 3
    MINOR = 0
    PATCH = 0

    # Returns a version string by joining <tt>MAJOR</tt>, <tt>MINOR</tt>, and <tt>PATCH</tt> with <tt>'.'</tt>
    #
    # Example
    #
    #   Version.to_s # '1.0.2'
    def self.to_s
      [MAJOR, MINOR, PATCH].join('.')
    end
  end
end
