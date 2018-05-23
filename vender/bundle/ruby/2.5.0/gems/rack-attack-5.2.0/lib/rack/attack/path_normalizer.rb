class Rack::Attack

  # When using Rack::Attack with a Rails app, developers expect the request path
  # to be normalized. In particular, trailing slashes are stripped.
  # (See http://git.io/v0rrR for implementation.)
  #
  # Look for an ActionDispatch utility class that Rails folks would expect
  # to normalize request paths. If unavailable, use a fallback class that
  # doesn't normalize the path (as a non-Rails rack app developer expects).

  module FallbackPathNormalizer
    def self.normalize_path(path)
      path
    end
  end

  PathNormalizer = if defined?(::ActionDispatch::Journey::Router::Utils)
                 # For Rails apps
                 ::ActionDispatch::Journey::Router::Utils
               else
                 FallbackPathNormalizer
               end

end
