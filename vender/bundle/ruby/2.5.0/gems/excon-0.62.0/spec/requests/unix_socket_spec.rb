require "spec_helper"

describe Excon::Connection do
  context "when speaking to a UNIX socket" do
    context "Host header handling" do
      before do
        responder = ->(req) do
          {
            body: req[:headers].to_json,
            status: 200,
          }
        end

        @original_mock = Excon.defaults[:mock]
        Excon.defaults[:mock] = true
        Excon.stub({}, responder)
      end

      after do
        Excon.defaults[:mock] = @original_mock
      end

      it "sends an empty Host= by default" do
        conn = Excon::Connection.new(
          scheme: "unix",
          socket: "/tmp/x.sock",
        )

        headers = JSON.parse(conn.get(path: "/path").body)

        expect(headers["Host"]).to eq("")
      end

      it "doesn't overwrite an explicit Host header" do
        conn = Excon::Connection.new(
          scheme: "unix",
          socket: "/tmp/x.sock",
        )

        headers = JSON.parse(conn.get(path: "/path", headers: { "Host" => "localhost" }).body)

        expect(headers["Host"]).to eq("localhost")
      end
    end
  end
end
