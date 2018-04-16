# frozen_string_literal: true

RSpec.describe HTTP::Options, "features" do
  let(:opts) { HTTP::Options.new }

  it "defaults to be empty" do
    expect(opts.features).to be_empty
  end

  it "accepts plain symbols in array" do
    opts2 = opts.with_features([:auto_inflate])
    expect(opts.features).to be_empty
    expect(opts2.features.keys).to eq([:auto_inflate])
    expect(opts2.features[:auto_inflate]).
      to be_instance_of(HTTP::Features::AutoInflate)
  end

  it "accepts feature name with its options in array" do
    opts2 = opts.with_features([{:auto_deflate => {:method => :deflate}}])
    expect(opts.features).to be_empty
    expect(opts2.features.keys).to eq([:auto_deflate])
    expect(opts2.features[:auto_deflate]).
      to be_instance_of(HTTP::Features::AutoDeflate)
    expect(opts2.features[:auto_deflate].method).to eq("deflate")
  end

  it "raises error for not supported features" do
    expect { opts.with_features([:wrong_feature]) }.
      to raise_error(HTTP::Error) { |error|
        expect(error.message).to eq("Unsupported feature: wrong_feature")
      }
  end
end
