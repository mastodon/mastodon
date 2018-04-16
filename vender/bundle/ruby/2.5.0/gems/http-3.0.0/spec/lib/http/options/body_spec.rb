# frozen_string_literal: true

RSpec.describe HTTP::Options, "body" do
  let(:opts) { HTTP::Options.new }

  it "defaults to nil" do
    expect(opts.body).to be nil
  end

  it "may be specified with with_body" do
    opts2 = opts.with_body("foo")
    expect(opts.body).to be nil
    expect(opts2.body).to eq("foo")
  end
end
