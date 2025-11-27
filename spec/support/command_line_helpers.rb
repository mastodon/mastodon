# frozen_string_literal: true

module CommandLineHelpers
  def output_results(*)
    output(
      include(*)
    ).to_stdout
  end
end

RSpec::Matchers.define_negated_matcher :not_output_results, :output_results
