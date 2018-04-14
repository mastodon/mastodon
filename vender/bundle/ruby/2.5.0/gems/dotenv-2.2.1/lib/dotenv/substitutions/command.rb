require "English"

module Dotenv
  module Substitutions
    # Substitute shell commands in a value.
    #
    #   SHA=$(git rev-parse HEAD)
    #
    module Command
      class << self
        INTERPOLATED_SHELL_COMMAND = /
          (?<backslash>\\)?   # is it escaped with a backslash?
          \$                  # literal $
          (?<cmd>             # collect command content for eval
            \(                # require opening paren
            ([^()]|\g<cmd>)+  # allow any number of non-parens, or balanced
                              # parens (by nesting the <cmd> expression
                              # recursively)
            \)                # require closing paren
          )
        /x

        def call(value, _env)
          # Process interpolated shell commands
          value.gsub(INTERPOLATED_SHELL_COMMAND) do |*|
            # Eliminate opening and closing parentheses
            command = $LAST_MATCH_INFO[:cmd][1..-2]

            if $LAST_MATCH_INFO[:backslash]
              # Command is escaped, don't replace it.
              $LAST_MATCH_INFO[0][1..-1]
            else
              # Execute the command and return the value
              `#{command}`.chomp
            end
          end
        end
      end
    end
  end
end
