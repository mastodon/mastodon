require 'rails_helper'

RSpec.describe HandleBadEncodingMiddleware do
  let(:app) { double() }
  let(:middleware) { HandleBadEncodingMiddleware.new(app) }

  it "request with query string is unchanged" do
    expect(app).to receive(:call).with("PATH" => "/some/path", "QUERY_STRING" => "name=fred")
    middleware.call("PATH" => "/some/path", "QUERY_STRING" => "name=fred")
  end

  it "request with no query string is unchanged" do
    expect(app).to receive(:call).with("PATH" => "/some/path")
    middleware.call("PATH" => "/some/path")
  end

  it "request with invalid encoding in query string drops query string" do
    expect(app).to receive(:call).with("QUERY_STRING" => "", "PATH" => "/some/path")
    middleware.call("QUERY_STRING" => "q=%2Fsearch%2Fall%Forder%3Ddescending%26page%3D5%26sort%3Dcreated_at", "PATH" => "/some/path")
  end
end
