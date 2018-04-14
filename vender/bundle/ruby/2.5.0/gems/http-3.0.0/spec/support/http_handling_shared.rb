# frozen_string_literal: true

RSpec.shared_context "HTTP handling" do
  describe "timeouts" do
    let(:conn_timeout) { 1 }
    let(:read_timeout) { 1 }
    let(:write_timeout) { 1 }

    let(:options) do
      {
        :timeout_class => timeout_class,
        :timeout_options => {
          :connect_timeout => conn_timeout,
          :read_timeout => read_timeout,
          :write_timeout => write_timeout
        }
      }
    end

    context "without timeouts" do
      let(:timeout_class) { HTTP::Timeout::Null }
      let(:conn_timeout) { 0 }
      let(:read_timeout) { 0 }
      let(:write_timeout) { 0 }

      it "works" do
        expect(client.get(server.endpoint).body.to_s).to eq("<!doctype html>")
      end
    end

    context "with a per operation timeout" do
      let(:timeout_class) { HTTP::Timeout::PerOperation }

      let(:response) { client.get(server.endpoint).body.to_s }

      it "works" do
        expect(response).to eq("<!doctype html>")
      end

      context "connection" do
        context "of 1" do
          let(:conn_timeout) { 1 }

          it "does not time out" do
            expect { response }.to_not raise_error
          end
        end
      end

      context "read" do
        context "of 0" do
          let(:read_timeout) { 0 }

          it "times out", :flaky do
            expect { response }.to raise_error(HTTP::TimeoutError, /Read/i)
          end
        end

        context "of 2.5" do
          let(:read_timeout) { 2.5 }

          it "does not time out", :flaky do
            expect { client.get("#{server.endpoint}/sleep").body.to_s }.to_not raise_error
          end
        end
      end
    end

    context "with a global timeout" do
      let(:timeout_class) { HTTP::Timeout::Global }

      let(:conn_timeout) { 0 }
      let(:read_timeout) { 1 }
      let(:write_timeout) { 0 }

      let(:response) { client.get(server.endpoint).body.to_s }

      it "errors if connecting takes too long" do
        expect(TCPSocket).to receive(:open) do
          sleep 1.25
        end

        expect { response }.to raise_error(HTTP::TimeoutError, /execution/)
      end

      it "errors if reading takes too long" do
        expect { client.get("#{server.endpoint}/sleep").body.to_s }.
          to raise_error(HTTP::TimeoutError, /Timed out/)
      end

      context "it resets state when reusing connections" do
        let(:extra_options) { {:persistent => server.endpoint} }

        let(:read_timeout) { 2.5 }

        it "does not timeout", :flaky do
          client.get("#{server.endpoint}/sleep").body.to_s
          client.get("#{server.endpoint}/sleep").body.to_s
        end
      end
    end
  end

  describe "connection reuse" do
    let(:sockets_used) do
      [
        client.get("#{server.endpoint}/socket/1").body.to_s,
        client.get("#{server.endpoint}/socket/2").body.to_s
      ]
    end

    context "when enabled" do
      let(:options) { {:persistent => server.endpoint} }

      context "without a host" do
        it "infers host from persistent config" do
          expect(client.get("/").body.to_s).to eq("<!doctype html>")
        end
      end

      it "re-uses the socket" do
        expect(sockets_used).to_not include("")
        expect(sockets_used.uniq.length).to eq(1)
      end

      context "on a mixed state" do
        it "re-opens the connection", :flaky do
          first_socket_id = client.get("#{server.endpoint}/socket/1").body.to_s

          client.instance_variable_set(:@state, :dirty)

          second_socket_id = client.get("#{server.endpoint}/socket/2").body.to_s

          expect(first_socket_id).to_not eq(second_socket_id)
        end
      end

      context "when trying to read a stale body" do
        it "errors" do
          client.get("#{server.endpoint}/not-found")
          expect { client.get(server.endpoint) }.to raise_error(HTTP::StateError, /Tried to send a request/)
        end
      end

      context "when reading a cached body" do
        it "succeeds" do
          first_res = client.get(server.endpoint)
          first_res.body.to_s

          second_res = client.get(server.endpoint)

          expect(first_res.body.to_s).to eq("<!doctype html>")
          expect(second_res.body.to_s).to eq("<!doctype html>")
        end
      end

      context "with a socket issue" do
        it "transparently reopens", :flaky do
          first_socket_id = client.get("#{server.endpoint}/socket").body.to_s
          expect(first_socket_id).to_not eq("")
          # Kill off the sockets we used
          # rubocop:disable Style/RescueModifier
          DummyServer::Servlet.sockets.each do |socket|
            socket.close rescue nil
          end
          DummyServer::Servlet.sockets.clear
          # rubocop:enable Style/RescueModifier

          # Should error because we tried to use a bad socket
          expect { client.get("#{server.endpoint}/socket").body.to_s }.to raise_error HTTP::ConnectionError

          # Should succeed since we create a new socket
          second_socket_id = client.get("#{server.endpoint}/socket").body.to_s
          expect(second_socket_id).to_not eq(first_socket_id)
        end
      end

      context "with a change in host" do
        it "errors" do
          expect { client.get("https://invalid.com/socket") }.to raise_error(/Persistence is enabled/i)
        end
      end
    end

    context "when disabled" do
      let(:options) { {} }

      it "opens new sockets", :flaky do
        expect(sockets_used).to_not include("")
        expect(sockets_used.uniq.length).to eq(2)
      end
    end
  end
end
