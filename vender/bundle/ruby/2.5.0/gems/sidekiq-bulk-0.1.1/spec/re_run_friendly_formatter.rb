require "rspec/core/formatters/progress_formatter"

class ReRunFriendlyFormatter < RSpec::Core::Formatters::ProgressFormatter
  RSpec::Core::Formatters.register self, :dump_summary

  def dump_summary(summary)
    super

    failed_files = summary.failed_examples.map { |e| RSpec::Core::Metadata::relative_path(e.file_path) }.uniq

    return if summary.failed_examples.empty? || failed_files.length > 10

    output.puts
    output.puts "Rerun all failed examples:"
    output.puts

    output.puts failure_colored("rspec #{summary.failed_examples.map { |e| RSpec::Core::Metadata::relative_path(e.location) }.uniq.join(" ")}")

    output.puts
    output.puts "Rerun all files containing failures:"
    output.puts

    output.puts failure_colored("rspec #{failed_files.uniq.join(" ")}")
  end

  private

  def failure_colored(str)
    RSpec::Core::Formatters::ConsoleCodes.wrap(str, :failure)
  end
end
