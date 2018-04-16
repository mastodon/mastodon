# Unlike other backends, require YAML if it's not already loaded
require 'yaml' unless defined?(YAML)

module OEmbed
  module Formatter
    module JSON
      module Backends
        # Use the YAML library, part of the standard library, to parse JSON values that has been converted to YAML.
        module Yaml
          extend self

          # Parses a JSON string or IO and converts it into an object.
          def decode(json)
            if json.respond_to?(:read)
              json = json.read
            end
            YAML.load(convert_json_to_yaml(json))
          rescue ArgumentError, Psych::SyntaxError
            raise parse_error, "Invalid JSON string"
          end
          
          def decode_fail_msg
            "The version of the YAML library you have installed isn't parsing JSON like ruby-oembed expected."
          end
          
          def parse_error
            ::StandardError
          end

          protected
            # Ensure that ":" and "," are always followed by a space
            def convert_json_to_yaml(json) #:nodoc:
              require 'strscan' unless defined? ::StringScanner
              scanner, quoting, marks, pos = ::StringScanner.new(json), false, [], nil
              scanner.scan_until(/\{/)
              while scanner.scan_until(/(\\['"]|['":,\\]|\\.)/)
                case char = scanner[1]
                when '"', "'"
                  if !quoting
                    quoting = char
                    pos = scanner.pos
                  elsif quoting == char
                    quoting = false
                  end
                when ":",","
                  marks << scanner.pos - 1 unless quoting
                when "\\"
                  scanner.skip(/\\/)
                end
              end
              raise parse_error unless scanner.scan_until(/\}/)

              if marks.empty?
                raise parse_error
              else
                left_pos  = [-1].push(*marks)
                right_pos = marks << scanner.pos + scanner.rest_size
                output    = []
                left_pos.each_with_index do |left, i|
                  scanner.pos = left.succ
                  chunk = scanner.peek(right_pos[i] - scanner.pos + 1)
                  chunk.gsub!(/\\([\\\/]|u[[:xdigit:]]{4})/) do
                    ustr = $1
                    if ustr.index('u') == 0
                      [ustr[1..-1].to_i(16)].pack("U")
                    elsif ustr == '\\'
                      '\\\\'
                    else
                      ustr
                    end
                  end
                  output << chunk
                end
                output = output * " "

                output.gsub!(/\\\//, '/')
                output
              end
            end
        
        end
      end
    end
  end
end
