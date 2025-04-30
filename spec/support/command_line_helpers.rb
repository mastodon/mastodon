# frozen_string_literal: true

module CommandLineHelpers
  def output_results(*)
    output(
      include(*)
    ).to_stdout
  end

  def not_output_results(*)
    output(
      not_include(*)
    ).to_stdout
  end
end
