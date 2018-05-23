require 'set'

module Aws

  # An auto-refreshing credential provider that works by assuming
  # a role via {Aws::STS::Client#assume_role}.
  #
  #     role_credentials = Aws::AssumeRoleCredentials.new(
  #       client: Aws::STS::Client.new(...),
  #       role_arn: "linked::account::arn",
  #       role_session_name: "session-name"
  #     )
  #
  #     ec2 = Aws::EC2::Client.new(credentials: role_credentials)
  #
  # If you omit `:client` option, a new {STS::Client} object will be
  # constructed.
  class AssumeRoleCredentials

    include CredentialProvider
    include RefreshingCredentials

    # @option options [required, String] :role_arn
    # @option options [required, String] :role_session_name
    # @option options [String] :policy
    # @option options [Integer] :duration_seconds
    # @option options [String] :external_id
    # @option options [STS::Client] :client
    def initialize(options = {})
      client_opts = {}
      @assume_role_params = {}
      options.each_pair do |key, value|
        if self.class.assume_role_options.include?(key)
          @assume_role_params[key] = value
        else
          client_opts[key] = value
        end
      end
      @client = client_opts[:client] || STS::Client.new(client_opts)
      super
    end

    # @return [STS::Client]
    attr_reader :client

    private

    def refresh
      c = @client.assume_role(@assume_role_params).credentials
      @credentials = Credentials.new(
        c.access_key_id,
        c.secret_access_key,
        c.session_token
      )
      @expiration = c.expiration
    end

    class << self

      # @api private
      def assume_role_options
        @aro ||= begin
          input = STS::Client.api.operation(:assume_role).input
          Set.new(input.shape.member_names)
        end
      end

    end
  end
end
