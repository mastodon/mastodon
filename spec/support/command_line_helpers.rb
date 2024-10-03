# frozen_string_literal: true

module CommandLineHelpers
  def output_results(*args)
    output(
      include(*args)
    ).to_stdout
  end
end
