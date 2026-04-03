# frozen_string_literal: true

module CommandLineHelpers
  def output_results(*)
    output(
      include(*)
    ).to_stdout
  end

  # `parallelize_with_progress` cannot run in transactions, so instead,
  # stub it with an alternative implementation that runs sequentially
  # and can run in transactions.
  def stub_parallelize_with_progress!
    allow(cli).to receive(:parallelize_with_progress) do |scope, &block|
      aggregate = 0
      total = 0

      scope.reorder(nil).find_each do |record|
        value = block.call(record)
        aggregate += value if value.is_a?(Integer)
        total += 1
      end

      [total, aggregate]
    end
  end
end

RSpec::Matchers.define_negated_matcher :not_output_results, :output_results
