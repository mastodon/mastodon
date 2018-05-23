# -*- encoding: utf-8 -*-
# frozen_string_literal: true
module JSON::LD
  ##
  # JSON-LD format specification.
  #
  # @example Obtaining an JSON-LD format class
  #     RDF::Format.for(:jsonld)           #=> JSON::LD::Format
  #     RDF::Format.for("etc/foaf.jsonld")
  #     RDF::Format.for(:file_name         => "etc/foaf.jsonld")
  #     RDF::Format.for(file_extension: "jsonld")
  #     RDF::Format.for(:content_type   => "application/ld+json")
  #
  # @example Obtaining serialization format MIME types
  #     RDF::Format.content_types      #=> {"application/ld+json" => [JSON::LD::Format],
  #                                         "application/x-ld+json" => [JSON::LD::Format]}
  #
  # @example Obtaining serialization format file extension mappings
  #     RDF::Format.file_extensions    #=> {:jsonld => [JSON::LD::Format] }
  #
  # @see http://www.w3.org/TR/json-ld/
  # @see https://json-ld.org/test-suite/
  class Format < RDF::Format
    content_type     'application/ld+json',
                     extension: :jsonld,
                     alias: 'application/x-ld+json'
    content_encoding 'utf-8'

    reader { JSON::LD::Reader }
    writer { JSON::LD::Writer }

    ##
    # Sample detection to see if it matches JSON-LD
    #
    # Use a text sample to detect the format of an input file. Sub-classes implement
    # a matcher sufficient to detect probably format matches, including disambiguating
    # between other similar formats.
    #
    # @param [String] sample Beginning several bytes (~ 1K) of input.
    # @return [Boolean]
    def self.detect(sample)
      !!sample.match(/\{\s*"@(id|context|type)"/m) &&
        # Exclude CSVW metadata
        !sample.include?("http://www.w3.org/ns/csvw")
    end

    ##
    # Hash of CLI commands appropriate for this format
    # @return [Hash{Symbol => Hash}]
    def self.cli_commands
      {
        expand: {
          description: "Expand JSON-LD or parsed RDF",
          parse: false,
          help: "expand [--context <context-file>] files ...",
          filter: {output_format: :jsonld},  # Only shows output format set
          lambda: ->(files, options) do
            out = options[:output] || $stdout
            out.set_encoding(Encoding::UTF_8) if RUBY_PLATFORM == "java"
            options = options.merge(expandContext: options.delete(:context)) if options.has_key?(:context)
            if options[:format] == :jsonld
              if files.empty?
                # If files are empty, either use options[:execute]
                input = options[:evaluate] ? StringIO.new(options[:evaluate]) : STDIN
                input.set_encoding(options.fetch(:encoding, Encoding::UTF_8))
                JSON::LD::API.expand(input, options.merge(validate: false)) do |expanded|
                  out.puts expanded.to_json(JSON::LD::JSON_STATE)
                end
              else
                files.each do |file|
                  JSON::LD::API.expand(file, options.merge(validate: false)) do |expanded|
                    out.puts expanded.to_json(JSON::LD::JSON_STATE)
                  end
                end
              end
            else
              # Turn RDF into JSON-LD first
              RDF::CLI.parse(files, options) do |reader|
                JSON::LD::API.fromRdf(reader) do |expanded|
                  out.puts expanded.to_json(JSON::LD::JSON_STATE)
                end
              end
            end
          end,
          option_use: {context: :removed}
        },
        compact: {
          description: "Compact JSON-LD or parsed RDF",
          parse: false,
          filter: {output_format: :jsonld},  # Only shows output format set
          help: "compact --context <context-file> files ...",
          lambda: ->(files, options) do
            raise ArgumentError, "Compacting requires a context" unless options[:context]
            out = options[:output] || $stdout
            out.set_encoding(Encoding::UTF_8) if RUBY_PLATFORM == "java"
            if options[:format] == :jsonld
              if files.empty?
                # If files are empty, either use options[:execute]
                input = options[:evaluate] ? StringIO.new(options[:evaluate]) : STDIN
                input.set_encoding(options.fetch(:encoding, Encoding::UTF_8))
                JSON::LD::API.compact(input, options[:context], options) do |compacted|
                  out.puts compacted.to_json(JSON::LD::JSON_STATE)
                end
              else
                files.each do |file|
                  JSON::LD::API.compact(file, options[:context], options) do |compacted|
                    out.puts compacted.to_json(JSON::LD::JSON_STATE)
                  end
                end
              end
            else
              # Turn RDF into JSON-LD first
              RDF::CLI.parse(files, options) do |reader|
                JSON::LD::API.fromRdf(reader) do |expanded|
                  JSON::LD::API.compact(expanded, options[:context], options) do |compacted|
                    out.puts compacted.to_json(JSON::LD::JSON_STATE)
                  end
                end
              end
            end
          end,
          options: [
            RDF::CLI::Option.new(
              symbol: :context,
              datatype: RDF::URI,
              control: :url2,
              use: :required,
              on: ["--context CONTEXT"],
              description: "Context to use when compacting.") {|arg| RDF::URI(arg)},
          ]
        },
        flatten: {
          description: "Flatten JSON-LD or parsed RDF",
          parse: false,
          help: "flatten [--context <context-file>] files ...",
          filter: {output_format: :jsonld},  # Only shows output format set
          lambda: ->(files, options) do
            out = options[:output] || $stdout
            out.set_encoding(Encoding::UTF_8) if RUBY_PLATFORM == "java"
            if options[:format] == :jsonld
              if files.empty?
                # If files are empty, either use options[:execute]
                input = options[:evaluate] ? StringIO.new(options[:evaluate]) : STDIN
                input.set_encoding(options.fetch(:encoding, Encoding::UTF_8))
                JSON::LD::API.flatten(input, options[:context], options) do |flattened|
                  out.puts flattened.to_json(JSON::LD::JSON_STATE)
                end
              else
                files.each do |file|
                  JSON::LD::API.flatten(file, options[:context], options) do |flattened|
                    out.puts flattened.to_json(JSON::LD::JSON_STATE)
                  end
                end
              end
            else
              # Turn RDF into JSON-LD first
              RDF::CLI.parse(files, options) do |reader|
                JSON::LD::API.fromRdf(reader) do |expanded|
                  JSON::LD::API.flatten(expanded, options[:context], options) do |flattened|
                    out.puts flattened.to_json(JSON::LD::JSON_STATE)
                  end
                end
              end
            end
          end
        },
        frame: {
          description: "Frame JSON-LD or parsed RDF",
          parse: false,
          help: "frame --frame <frame-file>  files ...",
          filter: {output_format: :jsonld},  # Only shows output format set
          lambda: ->(files, options) do
            raise ArgumentError, "Framing requires a frame" unless options[:frame]
            out = options[:output] || $stdout
            out.set_encoding(Encoding::UTF_8) if RUBY_PLATFORM == "java"
            if options[:format] == :jsonld
              if files.empty?
                # If files are empty, either use options[:execute]
                input = options[:evaluate] ? StringIO.new(options[:evaluate]) : STDIN
                input.set_encoding(options.fetch(:encoding, Encoding::UTF_8))
                JSON::LD::API.frame(input, options[:frame], options) do |framed|
                  out.puts framed.to_json(JSON::LD::JSON_STATE)
                end
              else
                files.each do |file|
                  JSON::LD::API.frame(file, options[:frame], options) do |framed|
                    out.puts framed.to_json(JSON::LD::JSON_STATE)
                  end
                end
              end
            else
              # Turn RDF into JSON-LD first
              RDF::CLI.parse(files, options) do |reader|
                JSON::LD::API.fromRdf(reader) do |expanded|
                  JSON::LD::API.frame(expanded, options[:frame], options) do |framed|
                    out.puts framed.to_json(JSON::LD::JSON_STATE)
                  end
                end
              end
            end
          end,
          option_use: {context: :removed},
          options: [
            RDF::CLI::Option.new(
              symbol: :frame,
              datatype: RDF::URI,
              control: :url2,
              use: :required,
              on: ["--frame FRAME"],
              description: "Frame to use when serializing.") {|arg| RDF::URI(arg)}
          ]
        },
      }
    end

    ##
    # Override normal symbol generation
    def self.to_sym
      :jsonld
    end

    ##
    # Override normal format name
    def self.name
      "JSON-LD"
    end
  end
end
