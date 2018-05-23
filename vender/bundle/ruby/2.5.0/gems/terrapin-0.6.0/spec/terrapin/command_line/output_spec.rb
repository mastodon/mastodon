require 'spec_helper'

describe Terrapin::CommandLine::Output do
  it 'holds an input and error stream' do
    output = Terrapin::CommandLine::Output.new(:a, :b)
    expect(output.output).to eq :a
    expect(output.error_output).to eq :b
  end

  it 'calls #to_s on the output when you call #to_s on it' do
    output = Terrapin::CommandLine::Output.new(:a, :b)
    expect(output.to_s).to eq 'a'
  end
end
