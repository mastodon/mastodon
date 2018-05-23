# frozen_string_literal: true
module Rake

  # Makefile loader to be used with the import file loader.  Use this to
  # import dependencies from make dependency tools:
  #
  #   require 'rake/loaders/makefile'
  #
  #   file ".depends.mf" => [SRC_LIST] do |t|
  #     sh "makedepend -f- -- #{CFLAGS} -- #{t.prerequisites} > #{t.name}"
  #   end
  #
  #   import ".depends.mf"
  #
  # See {Importing Dependencies}[link:doc/rakefile_rdoc.html#label-Importing+Dependencies]
  # for further details.

  class MakefileLoader
    include Rake::DSL

    SPACE_MARK = "\0" # :nodoc:

    # Load the makefile dependencies in +fn+.
    def load(fn) # :nodoc:
      lines = File.read fn
      lines.gsub!(/\\ /, SPACE_MARK)
      lines.gsub!(/#[^\n]*\n/m, "")
      lines.gsub!(/\\\n/, " ")
      lines.each_line do |line|
        process_line(line)
      end
    end

    private

    # Process one logical line of makefile data.
    def process_line(line) # :nodoc:
      file_tasks, args = line.split(":", 2)
      return if args.nil?
      dependents = args.split.map { |d| respace(d) }
      file_tasks.scan(/\S+/) do |file_task|
        file_task = respace(file_task)
        file file_task => dependents
      end
    end

    def respace(str) # :nodoc:
      str.tr SPACE_MARK, " "
    end
  end

  # Install the handler
  Rake.application.add_loader("mf", MakefileLoader.new)
end
