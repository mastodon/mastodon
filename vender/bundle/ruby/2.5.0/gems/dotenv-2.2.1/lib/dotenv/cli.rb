require "dotenv"

module Dotenv
  # The CLI is a class responsible of handling all the command line interface
  # logic.
  class CLI
    attr_reader :argv

    def initialize(argv = [])
      @argv = argv.dup
    end

    def run
      filenames = parse_filenames || []
      begin
        Dotenv.load!(*filenames)
      rescue Errno::ENOENT => e
        abort e.message
      else
        exec(*argv) unless argv.empty?
      end
    end

    private

    def parse_filenames
      pos = argv.index("-f")
      return nil unless pos
      # drop the -f
      argv.delete_at pos
      # parse one or more comma-separated .env files
      require "csv"
      CSV.parse_line argv.delete_at(pos)
    end
  end
end
