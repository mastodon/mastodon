# frozen_string_literal: true

require 'rails/generators/active_record'
require 'generators/devise/orm_helpers'

module ActiveRecord
  module Generators
    class DeviseGenerator < ActiveRecord::Generators::Base
      argument :attributes, type: :array, default: [], banner: "field:type field:type"

      class_option :primary_key_type, type: :string, desc: "The type for primary key"

      include Devise::Generators::OrmHelpers
      source_root File.expand_path("../templates", __FILE__)

      def copy_devise_migration
        if (behavior == :invoke && model_exists?) || (behavior == :revoke && migration_exists?(table_name))
          migration_template "migration_existing.rb", "#{migration_path}/add_devise_to_#{table_name}.rb", migration_version: migration_version
        else
          migration_template "migration.rb", "#{migration_path}/devise_create_#{table_name}.rb", migration_version: migration_version
        end
      end

      def generate_model
        invoke "active_record:model", [name], migration: false unless model_exists? && behavior == :invoke
      end

      def inject_devise_content
        content = model_contents

        class_path = if namespaced?
          class_name.to_s.split("::")
        else
          [class_name]
        end

        indent_depth = class_path.size - 1
        content = content.split("\n").map { |line| "  " * indent_depth + line } .join("\n") << "\n"

        inject_into_class(model_path, class_path.last, content) if model_exists?
      end

      def migration_data
<<RUBY
      ## Database authenticatable
      t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.#{ip_column} :current_sign_in_ip
      t.#{ip_column} :last_sign_in_ip

      ## Confirmable
      # t.string   :confirmation_token
      # t.datetime :confirmed_at
      # t.datetime :confirmation_sent_at
      # t.string   :unconfirmed_email # Only if using reconfirmable

      ## Lockable
      # t.integer  :failed_attempts, default: 0, null: false # Only if lock strategy is :failed_attempts
      # t.string   :unlock_token # Only if unlock strategy is :email or :both
      # t.datetime :locked_at
RUBY
      end

      def ip_column
        # Padded with spaces so it aligns nicely with the rest of the columns.
        "%-8s" % (inet? ? "inet" : "string")
      end

      def inet?
        postgresql?
      end

      def rails5?
        Rails.version.start_with? '5'
      end

      def postgresql?
        config = ActiveRecord::Base.configurations[Rails.env]
        config && config['adapter'] == 'postgresql'
      end

     def migration_version
       if rails5?
         "[#{Rails::VERSION::MAJOR}.#{Rails::VERSION::MINOR}]"
       end
     end

     def primary_key_type
       primary_key_string if rails5?
     end

     def primary_key_string
       key_string = options[:primary_key_type]
       ", id: :#{key_string}" if key_string
     end
    end
  end
end
