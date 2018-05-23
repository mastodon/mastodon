# frozen_string_literal: true

RSpec.describe HTTP::Options, "proxy" do
  let(:opts) { HTTP::Options.new }

  it "defaults to {}" do
    expect(opts.proxy).to eq({})
  end

  it "may be specified with with_proxy" do
    opts2 = opts.with_proxy(:proxy_address => "127.0.0.1", :proxy_port => 8080)
    expect(opts.proxy).to eq({})
    expect(opts2.proxy).to eq(:proxy_address => "127.0.0.1", :proxy_port => 8080)
  end

  it "accepts proxy address, port, username, and password" do
    opts2 = opts.with_proxy(:proxy_address => "127.0.0.1", :proxy_port => 8080, :proxy_username => "username", :proxy_password => "password")
    expect(opts2.proxy).to eq(:proxy_address => "127.0.0.1", :proxy_port => 8080, :proxy_username => "username", :proxy_password => "password")
  end
end
