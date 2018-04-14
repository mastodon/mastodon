# frozen_string_literal: true
module SimpleForm
  module Generators
    class InstallGenerator < Rails::Generators::Base
      desc "Copy SimpleForm default files"
      source_root File.expand_path('../templates', __FILE__)
      class_option :template_engine, desc: 'Template engine to be invoked (erb, haml or slim).'
      class_option :bootstrap, type: :boolean, desc: 'Add the Bootstrap wrappers to the SimpleForm initializer.'
      class_option :foundation, type: :boolean, desc: 'Add the Zurb Foundation 5 wrappers to the SimpleForm initializer.'

      def info_bootstrap
        return if options.bootstrap? || options.foundation?
        puts "SimpleForm 3 supports Bootstrap and Zurb Foundation 5. If you want "\
          "a configuration that is compatible with one of these frameworks, then please " \
          "re-run this generator with --bootstrap or --foundation as an option."
      end

      def copy_config
        template "config/initializers/simple_form.rb"

        if options[:bootstrap]
          template "config/initializers/simple_form_bootstrap.rb"
        elsif options[:foundation]
          template "config/initializers/simple_form_foundation.rb"
        end

        directory 'config/locales'
      end

      def copy_scaffold_template
        engine = options[:template_engine]
        copy_file "_form.html.#{engine}", "lib/templates/#{engine}/scaffold/_form.html.#{engine}"
      end

      def show_readme
        if behavior == :invoke && options.bootstrap?
          readme "README"
        end
      end
    end
  end
end
