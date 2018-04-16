module Doorkeeper
  module Models
    module Ownership
      extend ActiveSupport::Concern

      included do
        belongs_to_options = { polymorphic: true }
        if defined?(ActiveRecord::Base) && ActiveRecord::VERSION::MAJOR >= 5
          belongs_to_options[:optional] = true
        end

        belongs_to :owner, belongs_to_options
        validates :owner, presence: true, if: :validate_owner?
      end

      def validate_owner?
        Doorkeeper.configuration.confirm_application_owner?
      end
    end
  end
end
