# frozen_string_literal: true
require "rake/application"

module Rake

  class << self
    # Current Rake Application
    def application
      @application ||= Rake::Application.new
    end

    # Set the current Rake application object.
    def application=(app)
      @application = app
    end

    def suggested_thread_count # :nodoc:
      @cpu_count ||= Rake::CpuCounter.count
      @cpu_count + 4
    end

    # Return the original directory where the Rake application was started.
    def original_dir
      application.original_dir
    end

    # Load a rakefile.
    def load_rakefile(path)
      load(path)
    end

    # Add files to the rakelib list
    def add_rakelib(*files)
      application.options.rakelib ||= []
      application.options.rakelib.concat(files)
    end

    # Make +block_application+ the default rake application inside a block so
    # you can load rakefiles into a different application.
    #
    # This is useful when you want to run rake tasks inside a library without
    # running rake in a sub-shell.
    #
    # Example:
    #
    #   Dir.chdir 'other/directory'
    #
    #   other_rake = Rake.with_application do |rake|
    #     rake.load_rakefile
    #   end
    #
    #   puts other_rake.tasks

    def with_application(block_application = Rake::Application.new)
      orig_application = Rake.application

      Rake.application = block_application

      yield block_application

      block_application
    ensure
      Rake.application = orig_application
    end
  end

end
