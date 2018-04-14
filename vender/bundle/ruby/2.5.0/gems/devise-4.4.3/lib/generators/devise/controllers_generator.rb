# frozen_string_literal: true

require 'rails/generators/base'

module Devise
  module Generators
    class ControllersGenerator < Rails::Generators::Base
      CONTROLLERS = %w(confirmations passwords registrations sessions unlocks omniauth_callbacks).freeze

      desc <<-DESC.strip_heredoc
        Create inherited Devise controllers in your app/controllers folder.

        Use -c to specify which controller you want to overwrite.
        If you do no specify a controller, all controllers will be created.
        For example:

          rails generate devise:controllers users -c=sessions

        This will create a controller class at app/controllers/users/sessions_controller.rb like this:

          class Users::ConfirmationsController < Devise::ConfirmationsController
            content...
          end
      DESC

      source_root File.expand_path("../../templates/controllers", __FILE__)
      argument :scope, required: true,
        desc: "The scope to create controllers in, e.g. users, admins"
      class_option :controllers, aliases: "-c", type: :array,
        desc: "Select specific controllers to generate (#{CONTROLLERS.join(', ')})"

      def create_controllers
        @scope_prefix = scope.blank? ? '' : (scope.camelize + '::')
        controllers = options[:controllers] || CONTROLLERS
        controllers.each do |name|
          template "#{name}_controller.rb",
                   "app/controllers/#{scope}/#{name}_controller.rb"
        end
      end

      def show_readme
        readme "README" if behavior == :invoke
      end
    end
  end
end
