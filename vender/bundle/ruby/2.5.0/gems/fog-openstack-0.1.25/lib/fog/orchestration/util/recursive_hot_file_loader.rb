require 'set'
require 'yaml'
require 'open-uri'
require 'objspace'
require 'fog/core'

module Fog
  module Orchestration
    module Util
      #
      # Resolve get_file resources found in a HOT template populating
      #  a files Hash conforming to Heat Specs
      #  https://developer.openstack.org/api-ref/orchestration/v1/index.html?expanded=create-stack-detail#stacks
      #
      # Files present in :files are not processed further. The others
      #   are added to the Hash. This behavior is the same implemented in openstack-infra/shade
      #   see https://github.com/openstack-infra/shade/blob/1d16f64fbf376a956cafed1b3edd8e51ccc16f2c/shade/openstackcloud.py#L1200
      #
      # This implementation just process nested templates but not resource
      #  registries.
      class RecursiveHotFileLoader
        attr_reader :files
        attr_reader :template

        def initialize(template, files = nil)
          # According to https://github.com/fog/fog-openstack/blame/master/docs/orchestration.md#L122
          #  templates can be either String or Hash.
          #  If it's an Hash, we deep_copy it so the passed argument
          #  is not modified by get_file_contents.
          template = deep_copy(template)
          @visited = Set.new
          @files = files || {}
          @template = get_template_contents(template)
        end

        # Return string
        def url_join(prefix, suffix)
          if prefix
            # URI.join replaces prefix parts before a
            #  trailing slash. See https://docs.ruby-lang.org/en/2.3.0/URI.html.
            prefix += '/' unless prefix.to_s.end_with?("/")
            suffix = URI.join(prefix, suffix)
            # Force URI to use traditional file scheme representation.
            suffix.host = "" if suffix.scheme == "file"
          end
          suffix.to_s
        end

        # Retrieve a template content.
        #
        # @param template_file can be either:
        #          - a raw_template string
        #          - an URI string
        #          - an Hash containing the parsed template.
        #
        # XXX: we could use named parameters
        # and better mimic heatclient implementation.
        def get_template_contents(template_file)
          Fog::Logger.debug("get_template_contents [#{template_file}]")

          raise "template_file should be Hash or String, not #{template_file.class.name}" unless
            template_file.kind_of?(String) || template_file.kind_of?(Hash)

          local_base_url = url_join("file:/", File.absolute_path(Dir.pwd))

          if template_file.kind_of?(Hash)
            template_base_url = local_base_url
            template = template_file
          elsif template_is_raw?(template_file)
            template_base_url = local_base_url
            template = YAML.safe_load(template_file, [Date])
          elsif template_is_url?(template_file)
            template_file = normalise_file_path_to_url(template_file)
            template_base_url = base_url_for_url(template_file)
            raw_template = read_uri(template_file)
            template = YAML.safe_load(raw_template, [Date])

            Fog::Logger.debug("Template visited: #{@visited}")
            @visited.add(template_file)
          else
            raise "template_file is not a string of the expected form"
          end

          get_file_contents(template, template_base_url)

          template
        end

        # Traverse the template tree looking for get_file and type
        #   and populating the @files attribute with their content.
        #   Resource referenced by get_file and type are eventually
        #   replaced with their absolute URI as done in heatclient
        #   and shade.
        #
        def get_file_contents(from_data, base_url)
          Fog::Logger.debug("Processing #{from_data} with base_url #{base_url}")

          # Recursively traverse the tree
          #   if recurse_data is Array or Hash
          recurse_data = from_data.kind_of?(Hash) ? from_data.values : from_data
          recurse_data.each { |value| get_file_contents(value, base_url) } if recurse_data.kind_of?(Array)

          # I'm on a Hash, process it.
          return unless from_data.kind_of?(Hash)
          from_data.each do |key, value|
            next if ignore_if(key, value)

            # Resolve relative paths.
            str_url = url_join(base_url, value)

            next if @files.key?(str_url)

            file_content = read_uri(str_url)

            # get_file should not recurse hot templates.
            if key == "type" && template_is_raw?(file_content) && !@visited.include?(str_url)
              template = get_template_contents(str_url)
              file_content = YAML.dump(template)
            end

            @files[str_url] = file_content
            # replace the data value with the normalised absolute URL as required
            #  by https://docs.openstack.org/heat/pike/template_guide/hot_spec.html#get-file
            from_data[key] = str_url
          end
        end

        private

        # Retrive the content of a local or remote file.
        #
        # @param A local or remote uri.
        #
        # @raise ArgumentError if it's not a valid uri
        #
        # Protect open-uri from malign arguments like
        #  - "|ls"
        #  - multiline strings
        def read_uri(uri_or_filename)
          remote_schemes = %w[http https ftp]
          Fog::Logger.debug("Opening #{uri_or_filename}")

          begin
            # Validate URI to protect from open-uri attacks.
            url = URI(uri_or_filename)

            if remote_schemes.include?(url.scheme)
              # Remote schemes must contain an host.
              raise ArgumentError if url.host.nil?

              # Encode URI with spaces.
              uri_or_filename = uri_or_filename.gsub(/ /, "%20")
            end
          rescue URI::InvalidURIError
            raise ArgumentError, "Not a valid URI: #{uri_or_filename}"
          end

          # TODO: A future revision may implement a retry.
          content = ''
          # open-uri doesn't open "file:///" uris.
          uri_or_filename = uri_or_filename.sub(/^file:/, "")

          open(uri_or_filename) { |f| content = f.read }
          content
        end

        # Return true if the file is an heat template, false otherwise.
        def template_is_raw?(content)
          htv = content.strip.index("heat_template_version")
          # Tolerate some leading character in case of a json template.
          htv && htv < 5
        end

        # Return true if it's an URI, false otherwise.
        def template_is_url?(path)
          normalise_file_path_to_url(path)
          true
        rescue ArgumentError, URI::InvalidURIError
          false
        end

        # Return true if I should I process this this file.
        #
        # @param [String] An heat template key
        #
        def ignore_if(key, value)
          return true if key != 'get_file' && key != 'type'

          return true unless value.kind_of?(String)

          return true if key == 'type' &&
                         !value.end_with?('.yaml', '.template')

          false
        end

        # Returns the string baseurl of the given url.
        def base_url_for_url(url)
          parsed = URI(url)
          parsed_dir = File.dirname(parsed.path)
          url_join(parsed, parsed_dir)
        end

        def normalise_file_path_to_url(path)
          # Nothing to do on URIs
          return path if URI(path).scheme

          path = File.absolute_path(path)
          url_join('file:/', path)
        end

        def deep_copy(item)
          return item if item.kind_of?(String)

          YAML.safe_load(YAML.dump(item), [Date])
        end
      end
    end
  end
end
