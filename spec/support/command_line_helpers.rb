# frozen_string_literal: true

module CommandLineHelpers
  def output_results(string)
    output(
      a_string_including(string)
    ).to_stdout
  end
end
