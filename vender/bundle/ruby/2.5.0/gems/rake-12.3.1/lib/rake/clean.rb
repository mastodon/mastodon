# frozen_string_literal: true
# The 'rake/clean' file defines two file lists (CLEAN and CLOBBER) and
# two rake tasks (:clean and :clobber).
#
# [:clean] Clean up the project by deleting scratch files and backup
#          files.  Add files to the CLEAN file list to have the :clean
#          target handle them.
#
# [:clobber] Clobber all generated and non-source files in a project.
#            The task depends on :clean, so all the clean files will
#            be deleted as well as files in the CLOBBER file list.
#            The intent of this task is to return a project to its
#            pristine, just unpacked state.

require "rake"

# :stopdoc:

module Rake
  module Cleaner
    extend FileUtils

    module_function

    def cleanup_files(file_names)
      file_names.each do |file_name|
        cleanup(file_name)
      end
    end

    def cleanup(file_name, opts={})
      begin
        opts = { verbose: Rake.application.options.trace }.merge(opts)
        rm_r file_name, opts
      rescue StandardError => ex
        puts "Failed to remove #{file_name}: #{ex}" unless file_already_gone?(file_name)
      end
    end

    def file_already_gone?(file_name)
      return false if File.exist?(file_name)

      path = file_name
      prev = nil

      while path = File.dirname(path)
        return false if cant_be_deleted?(path)
        break if [prev, "."].include?(path)
        prev = path
      end
      true
    end
    private_class_method :file_already_gone?

    def cant_be_deleted?(path_name)
      File.exist?(path_name) &&
        (!File.readable?(path_name) || !File.executable?(path_name))
    end
    private_class_method :cant_be_deleted?
  end
end

CLEAN = ::Rake::FileList["**/*~", "**/*.bak", "**/core"]
CLEAN.clear_exclude.exclude { |fn|
  fn.pathmap("%f").downcase == "core" && File.directory?(fn)
}

desc "Remove any temporary products."
task :clean do
  Rake::Cleaner.cleanup_files(CLEAN)
end

CLOBBER = ::Rake::FileList.new

desc "Remove any generated files."
task clobber: [:clean] do
  Rake::Cleaner.cleanup_files(CLOBBER)
end
