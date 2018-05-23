# frozen_string_literal: true

RSpec.describe HTTP::Options, "json" do
  let(:opts) { HTTP::Options.new }

  it "defaults to nil" do
    expect(opts.json).to be nil
  end

  it "may be specified with with_json data" do
    opts2 = opts.with_json(:foo => 42)
    expect(opts.json).to be nil
    expect(opts2.json).to eq(:foo => 42)
  end
end
