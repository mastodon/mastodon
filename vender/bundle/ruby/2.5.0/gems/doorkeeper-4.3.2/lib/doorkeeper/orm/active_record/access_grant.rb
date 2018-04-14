module Doorkeeper
  class AccessGrant < ActiveRecord::Base
    self.table_name = "#{table_name_prefix}oauth_access_grants#{table_name_suffix}".to_sym

    include AccessGrantMixin
    include ActiveModel::MassAssignmentSecurity if defined?(::ProtectedAttributes)

    belongs_to_options = {
      class_name: 'Doorkeeper::Application',
      inverse_of: :access_grants
    }

    if defined?(ActiveRecord::Base) && ActiveRecord::VERSION::MAJOR >= 5
      belongs_to_options[:optional] = true
    end

    belongs_to :application, belongs_to_options

    validates :resource_owner_id, :application_id, :token, :expires_in, :redirect_uri, presence: true
    validates :token, uniqueness: true

    before_validation :generate_token, on: :create

    private

    # Generates token value with UniqueToken class.
    #
    # @return [String] token value
    #
    def generate_token
      self.token = UniqueToken.generate
    end
  end
end
