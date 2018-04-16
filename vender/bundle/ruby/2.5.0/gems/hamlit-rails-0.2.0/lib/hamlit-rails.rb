require "hamlit-rails/version"
require "rails"
require "hamlit"
require "hamlit/railtie"

module Haml
  module Rails
    class Engine < ::Rails::Engine
      config.app_generators do |g|
        g.template_engine :haml
      end
    end
    class Railtie < ::Rails::Railtie
      config.app_generators.template_engine :haml

      initializer 'hamlit_rails.configure_template_digestor' do

        ActiveSupport.on_load(:action_view) do
          ActiveSupport.on_load(:after_initialize) do
            begin
              if defined?(CacheDigests::DependencyTracker)
                # 'cache_digests' gem being used (overrides Rails 4 implementation)
                CacheDigests::DependencyTracker.register_tracker :haml, CacheDigests::DependencyTracker::ERBTracker

                if ::Rails.env.development?
                  # recalculate cache digest keys for each request
                  CacheDigests::TemplateDigestor.cache = ActiveSupport::Cache::NullStore.new
                end
              elsif ::Rails.version.to_s >= '4.0'
                # will only apply if Rails 4, which includes 'action_view/dependency_tracker'
                require 'action_view/dependency_tracker'
                ActionView::DependencyTracker.register_tracker :haml, ActionView::DependencyTracker::ERBTracker
                ActionView::Base.cache_template_loading = false if ::Rails.env.development?
              end
            rescue
              # likely this version of Rails doesn't support dependency tracking
            end
          end
        end
      end

      # Configure source annotation on haml files (support for HAML was
      # provided directly by railties 3.2..4.1 but was dropped in 4.2.
      if Gem::Requirement.new(">= 4.2").satisfied_by?(Gem::Version.new(::Rails.version))
        initializer 'hamlit_rails.configure_source_annotation' do
          SourceAnnotationExtractor::Annotation.register_extensions('haml') do |tag|
            /\s*-#\s*(#{tag}):?\s*(.*)/
          end
        end
      end

      rake_tasks do
        load 'hamlit-rails/erb2haml.rake'
      end
    end
  end
end
