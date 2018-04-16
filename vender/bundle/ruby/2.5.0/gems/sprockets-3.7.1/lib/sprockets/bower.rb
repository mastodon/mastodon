require 'json'

module Sprockets
  module Bower
    # Internal: All supported bower.json files.
    #
    # https://github.com/bower/json/blob/0.4.0/lib/json.js#L7
    POSSIBLE_BOWER_JSONS = ['bower.json', 'component.json', '.bower.json']

    # Internal: Override resolve_alternates to install bower.json behavior.
    #
    # load_path    - String environment path
    # logical_path - String path relative to base
    #
    # Returns candiate filenames.
    def resolve_alternates(load_path, logical_path)
      candidates, deps = super

      # bower.json can only be nested one level deep
      if !logical_path.index('/')
        dirname = File.join(load_path, logical_path)

        if directory?(dirname)
          filenames = POSSIBLE_BOWER_JSONS.map { |basename| File.join(dirname, basename) }
          filename  = filenames.detect { |fn| self.file?(fn) }

          if filename
            deps << build_file_digest_uri(filename)
            read_bower_main(dirname, filename) do |path|
              candidates << path
            end
          end
        end
      end

      return candidates, deps
    end

    # Internal: Read bower.json's main directive.
    #
    # dirname  - String path to component directory.
    # filename - String path to bower.json.
    #
    # Returns nothing.
    def read_bower_main(dirname, filename)
      bower = JSON.parse(File.read(filename), create_additions: false)

      case bower['main']
      when String
        yield File.expand_path(bower['main'], dirname)
      when Array
        bower['main'].each do |name|
          yield File.expand_path(name, dirname)
        end
      end
    end
  end
end
