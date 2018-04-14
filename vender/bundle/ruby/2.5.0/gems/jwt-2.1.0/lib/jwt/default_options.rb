module JWT
  module DefaultOptions
    DEFAULT_OPTIONS = {
      verify_expiration: true,
      verify_not_before: true,
      verify_iss: false,
      verify_iat: false,
      verify_jti: false,
      verify_aud: false,
      verify_sub: false,
      leeway: 0,
      algorithms: ['HS256']
    }.freeze
  end
end
