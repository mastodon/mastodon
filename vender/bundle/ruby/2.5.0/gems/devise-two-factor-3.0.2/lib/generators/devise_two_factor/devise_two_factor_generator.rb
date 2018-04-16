require 'rails/generators'

module DeviseTwoFactor
  module Generators
    class DeviseTwoFactorGenerator < Rails::Generators::NamedBase
      argument :encryption_key_env, :type => :string, :required => true

      desc 'Creates a migration to add the required attributes to NAME, and ' \
           'adds the necessary Devise directives to the model'

      def install_devise_two_factor
        create_devise_two_factor_migration
        inject_strategies_into_warden_config
        inject_devise_directives_into_model
      end

    private

      def create_devise_two_factor_migration
        migration_arguments = [
                                "add_devise_two_factor_to_#{plural_name}",
                                "encrypted_otp_secret:string",
                                "encrypted_otp_secret_iv:string",
                                "encrypted_otp_secret_salt:string",
                                "consumed_timestep:integer",
                                "otp_required_for_login:boolean"
                              ]

        Rails::Generators.invoke('active_record:migration', migration_arguments)
      end

      def inject_strategies_into_warden_config
        config_path = File.join('config', 'initializers', 'devise.rb')

        content = "  config.warden do |manager|\n" \
                  "    manager.default_strategies(:scope => :#{singular_table_name}).unshift :two_factor_authenticatable\n" \
                  "  end\n\n"

        inject_into_file(config_path, content, after: "Devise.setup do |config|\n")
      end

      def inject_devise_directives_into_model
        model_path = File.join('app', 'models', "#{file_path}.rb")

        class_path = if namespaced?
          class_name.to_s.split("::")
        else
          [class_name]
        end

        indent_depth = class_path.size

        content = [
                    "devise :two_factor_authenticatable,",
                    "       :otp_secret_encryption_key => ENV['#{encryption_key_env}']\n"
                  ]

        content << "attr_accessible :otp_attempt\n" if needs_attr_accessible?
        content = content.map { |line| "  " * indent_depth + line }.join("\n") << "\n"

        inject_into_class(model_path, class_path.last, content)

        # Remove :database_authenticatable from the list of loaded models
        gsub_file(model_path, /(devise.*):(, )?database_authenticatable(, )?/, '\1\2')
      end

      def needs_attr_accessible?
        !strong_parameters_enabled? && mass_assignment_security_enabled?
      end

      def strong_parameters_enabled?
        defined?(ActionController::StrongParameters)
      end

      def mass_assignment_security_enabled?
        defined?(ActiveModel::MassAssignmentSecurity)
      end
    end
  end
end
