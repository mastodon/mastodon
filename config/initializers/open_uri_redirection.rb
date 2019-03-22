require 'open-uri'

module OpenURI
  def self.redirectable?(uri1, uri2) # :nodoc:
    uri1.scheme.casecmp(uri2.scheme).zero? ||
      (/\A(?:http|https|ftp)\z/i =~ uri1.scheme && /\A(?:http|https|ftp)\z/i =~ uri2.scheme)
  end
end
