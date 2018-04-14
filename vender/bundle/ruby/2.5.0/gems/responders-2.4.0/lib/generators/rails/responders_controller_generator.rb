require 'rails/generators/rails/scaffold_controller/scaffold_controller_generator'

module Rails
  module Generators
    class RespondersControllerGenerator < ScaffoldControllerGenerator
      source_root File.expand_path("../templates", __FILE__)

      protected

      def flash?
        if defined?(ApplicationController)
          !ApplicationController.responder.ancestors.include?(Responders::FlashResponder)
        else
          Rails.application.config.responders.flash_keys.blank?
        end
      end

      def attributes_params
        "#{singular_table_name}_params"
      end
    end
  end
end
