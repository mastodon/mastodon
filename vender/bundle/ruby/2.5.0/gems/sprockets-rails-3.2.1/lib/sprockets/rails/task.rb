require 'rake'
require 'rake/sprocketstask'
require 'sprockets'
require 'action_view'
require 'action_view/base'

module Sprockets
  module Rails
    class Task < Rake::SprocketsTask
      attr_accessor :app

      def initialize(app = nil)
        self.app = app
        super()
      end

      def environment
        if app
          # Use initialized app.assets or force build an environment if
          # config.assets.compile is disabled
          app.assets || Sprockets::Railtie.build_environment(app)
        else
          super
        end
      end

      def output
        if app
          config = app.config
          File.join(config.paths['public'].first, config.assets.prefix)
        else
          super
        end
      end

      def assets
        if app
          app.config.assets.precompile
        else
          super
        end
      end

      def manifest
        if app
          Sprockets::Manifest.new(index, output, app.config.assets.manifest)
        else
          super
        end
      end

      def define
        namespace :assets do
          %w( environment precompile clean clobber ).each do |task|
            Rake::Task[task].clear if Rake::Task.task_defined?(task)
          end

          # Override this task change the loaded dependencies
          desc "Load asset compile environment"
          task :environment do
            # Load full Rails environment by default
            Rake::Task['environment'].invoke
          end

          desc "Compile all the assets named in config.assets.precompile"
          task :precompile => :environment do
            with_logger do
              manifest.compile(assets)
            end
          end

          desc "Remove old compiled assets"
          task :clean, [:keep] => :environment do |t, args|
            with_logger do
              manifest.clean(Integer(args.keep || self.keep))
            end
          end

          desc "Remove compiled assets"
          task :clobber => :environment do
            with_logger do
              manifest.clobber
            end
          end
        end
      end
    end
  end
end
