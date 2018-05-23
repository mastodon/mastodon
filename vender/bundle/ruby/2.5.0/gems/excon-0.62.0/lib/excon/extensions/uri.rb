# frozen_string_literal: true
# TODO: Remove this monkey patch once ruby 1.9.3+ is the minimum supported version.
#
# This patch backports URI#hostname to ruby 1.9.2 and older.
# URI#hostname is used for IPv6 support in Excon.
#
# URI#hostname was added in stdlib in v1_9_3_0 in this commit:
#   https://github.com/ruby/ruby/commit/5fd45a4b79dd26f9e7b6dc41142912df911e4d7d
#
# Addressable::URI is also an URI parser accepted in some parts of Excon.
# Addressable::URI#hostname was added in addressable-2.3.5+ in this commit:
#   https://github.com/sporkmonger/addressable/commit/1b94abbec1f914d5f707c92a10efbb9e69aab65e
#
# Users who want to use Addressable::URI to parse URIs must upgrade to 2.3.5 or newer.
require 'uri'
unless URI("http://foo/bar").respond_to?(:hostname)
  module URI
    class Generic
      # extract the host part of the URI and unwrap brackets for IPv6 addresses.
      #
      # This method is same as URI::Generic#host except
      # brackets for IPv6 (and future IP) addresses are removed.
      #
      # u = URI("http://[::1]/bar")
      # p u.hostname      #=> "::1"
      # p u.host          #=> "[::1]"
      #
      def hostname
        v = self.host
        /\A\[(.*)\]\z/ =~ v ? $1 : v
      end
    end
  end
end
