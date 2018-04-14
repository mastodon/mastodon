# frozen_string_literal: true
module Rake
  module TraceOutput # :nodoc: all

    # Write trace output to output stream +out+.
    #
    # The write is done as a single IO call (to print) to lessen the
    # chance that the trace output is interrupted by other tasks also
    # producing output.
    def trace_on(out, *strings)
      sep = $\ || "\n"
      if strings.empty?
        output = sep
      else
        output = strings.map { |s|
          next if s.nil?
          s.end_with?(sep) ? s : s + sep
        }.join
      end
      out.print(output)
    end
  end
end
