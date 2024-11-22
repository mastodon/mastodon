# frozen_string_literal: true

module CommandLineHelpers
  def output_results(*)
    output(
      include(*)
    ).to_stdout
  end
end
