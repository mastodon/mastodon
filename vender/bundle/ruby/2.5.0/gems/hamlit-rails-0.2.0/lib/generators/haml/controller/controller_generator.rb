require 'rails/generators/erb/controller/controller_generator'

module Haml
  module Generators
    class ControllerGenerator < Erb::Generators::ControllerGenerator
      source_root File.expand_path("../templates", __FILE__)

      protected

      def handler
        :haml
      end

    end
  end
end