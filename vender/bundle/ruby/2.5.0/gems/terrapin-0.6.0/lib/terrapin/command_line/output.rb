class Terrapin::CommandLine::Output
  def initialize(output = nil, error_output = nil)
    @output = output
    @error_output = error_output
  end

  attr_reader :output, :error_output

  def to_s
    output.to_s
  end
end
