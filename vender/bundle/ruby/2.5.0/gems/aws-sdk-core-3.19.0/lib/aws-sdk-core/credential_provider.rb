require_relative 'deprecations'

module Aws
  module CredentialProvider

    extend Deprecations

    # @return [Credentials]
    attr_reader :credentials

    # @return [Boolean]
    def set?
      !!credentials && credentials.set?
    end

    # @deprecated Deprecated in 2.1.0. This method is subject to errors
    #   from a race condition when called against refreshable credential
    #   objects. Will be removed in 2.2.0.
    # @see #credentials
    def access_key_id
      credentials ? credentials.access_key_id : nil
    end
    deprecated(:access_key_id, use: '#credentials')

    # @deprecated Deprecated in 2.1.0. This method is subject to errors
    #   from a race condition when called against refreshable credential
    #   objects. Will be removed in 2.2.0.
    # @see #credentials
    def secret_access_key
      credentials ? credentials.secret_access_key : nil
    end
    deprecated(:secret_access_key, use: '#credentials')

    # @deprecated Deprecated in 2.1.0. This method is subject to errors
    #   from a race condition when called against refreshable credential
    #   objects. Will be removed in 2.2.0.
    # @see #credentials
    def session_token
      credentials ? credentials.session_token : nil
    end
    deprecated(:session_token, use: '#credentials')

  end
end
