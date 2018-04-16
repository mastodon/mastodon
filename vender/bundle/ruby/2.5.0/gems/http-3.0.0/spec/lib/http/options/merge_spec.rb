# frozen_string_literal: true

RSpec.describe HTTP::Options, "merge" do
  let(:opts) { HTTP::Options.new }

  it "supports a Hash" do
    old_response = opts.response
    expect(opts.merge(:response => :body).response).to eq(:body)
    expect(opts.response).to eq(old_response)
  end

  it "supports another Options" do
    merged = opts.merge(HTTP::Options.new(:response => :body))
    expect(merged.response).to eq(:body)
  end

  it "merges as excepted in complex cases" do
    # FIXME: yuck :(

    foo = HTTP::Options.new(
      :response  => :body,
      :params    => {:baz => "bar"},
      :form      => {:foo => "foo"},
      :body      => "body-foo",
      :json      => {:foo => "foo"},
      :headers   => {:accept => "json", :foo => "foo"},
      :proxy     => {},
      :features  => {}
    )

    bar = HTTP::Options.new(
      :response   => :parsed_body,
      :persistent => "https://www.googe.com",
      :params     => {:plop => "plip"},
      :form       => {:bar => "bar"},
      :body       => "body-bar",
      :json       => {:bar => "bar"},
      :keep_alive_timeout => 10,
      :headers            => {:accept => "xml", :bar => "bar"},
      :timeout_options    => {:foo => :bar},
      :ssl        => {:foo => "bar"},
      :proxy      => {:proxy_address => "127.0.0.1", :proxy_port => 8080}
    )

    expect(foo.merge(bar).to_hash).to eq(
      :response           => :parsed_body,
      :timeout_class      => described_class.default_timeout_class,
      :timeout_options    => {:foo => :bar},
      :params             => {:plop => "plip"},
      :form               => {:bar => "bar"},
      :body               => "body-bar",
      :json               => {:bar => "bar"},
      :persistent         => "https://www.googe.com",
      :keep_alive_timeout => 10,
      :ssl                => {:foo => "bar"},
      :headers            => {"Foo" => "foo", "Accept" => "xml", "Bar" => "bar"},
      :proxy              => {:proxy_address => "127.0.0.1", :proxy_port => 8080},
      :follow             => nil,
      :socket_class       => described_class.default_socket_class,
      :nodelay            => false,
      :ssl_socket_class   => described_class.default_ssl_socket_class,
      :ssl_context        => nil,
      :cookies            => {},
      :encoding           => nil,
      :features           => {}
    )
  end
end
