# frozen_string_literal: true

RSpec.describe HTTP::Options, "new" do
  it "supports a Options instance" do
    opts = HTTP::Options.new
    expect(HTTP::Options.new(opts)).to eq(opts)
  end

  context "with a Hash" do
    it "coerces :response correctly" do
      opts = HTTP::Options.new(:response => :object)
      expect(opts.response).to eq(:object)
    end

    it "coerces :headers correctly" do
      opts = HTTP::Options.new(:headers => {:accept => "json"})
      expect(opts.headers).to eq([%w[Accept json]])
    end

    it "coerces :proxy correctly" do
      opts = HTTP::Options.new(:proxy => {:proxy_address => "127.0.0.1", :proxy_port => 8080})
      expect(opts.proxy).to eq(:proxy_address => "127.0.0.1", :proxy_port => 8080)
    end

    it "coerces :form correctly" do
      opts = HTTP::Options.new(:form => {:foo => 42})
      expect(opts.form).to eq(:foo => 42)
    end
  end
end
