require "spec_helper"
require "fog/compute/models/server"

describe Fog::Compute::Server do
  before do
    @server = Fog::Compute::Server.new
  end

  describe "#sshable?" do
    describe "when the server is not ready" do
      it "is false" do
        @server.stub(:ready?, false) do
          refute @server.sshable?
        end
      end
    end

    describe "when the server is ready" do
      describe "when the ssh_ip_address is nil" do
        it "is false" do
          @server.stub(:ready?, true) do
            @server.stub(:ssh_ip_address, nil) do
              refute @server.sshable?
            end
          end
        end
      end


      describe "when the ssh_ip_address exists" do
        # Define these constants which would be imported by net-ssh once loaded
        module Net
          module SSH
            class AuthenticationFailed  < RuntimeError
            end
            class Disconnect < RuntimeError
            end
          end
        end

        describe "and ssh times out" do
          it "is false" do
            @server.stub(:ready?, true) do
              @server.stub(:ssh_ip_address, "10.0.0.1") do
                raises_timeout = lambda { |_time| raise Timeout::Error.new }
                Timeout.stub(:timeout, raises_timeout) do
                  refute @server.sshable?
                end
              end
            end
          end
        end

        describe "and it raises Net::SSH::AuthenticationFailed" do
          it "is false" do
            @server.stub(:ready?, true) do
              @server.stub(:ssh_ip_address, "10.0.0.1") do
                raise_error = lambda { |_cmd, _options| raise Net::SSH::AuthenticationFailed.new }
                @server.stub(:ssh, raise_error) do
                  refute @server.sshable?
                end
              end
            end
          end

          it "resets SSH timeout" do
            @server.instance_variable_set(:@sshable_timeout, 8)
            @server.stub(:ready?, true) do
              @server.stub(:ssh_ip_address, "10.0.0.1") do
                raise_error = lambda { |_cmd, _options| raise Net::SSH::AuthenticationFailed.new }
                @server.stub(:ssh, raise_error) do
                  @server.sshable?
                  assert_nil @server.instance_variable_get(:@sshable_timeout), nil
                end
              end
            end
          end
        end

        describe "and it raises Net::SSH::Disconnect" do
          it "is false" do
            @server.stub(:ready?, true) do
              @server.stub(:ssh_ip_address, "10.0.0.1") do
                raise_error = lambda { |_cmd, _options| raise Net::SSH::Disconnect.new }
                @server.stub(:ssh, raise_error) do
                  refute @server.sshable?
                end
              end
            end
          end

          it "resets SSH timeout" do
            @server.instance_variable_set(:@sshable_timeout, 8)
            @server.stub(:ready?, true) do
              @server.stub(:ssh_ip_address, "10.0.0.1") do
                raise_error = lambda { |_cmd, _options| raise Net::SSH::Disconnect.new }
                @server.stub(:ssh, raise_error) do
                  @server.sshable?
                  assert_nil @server.instance_variable_get(:@sshable_timeout), nil
                end
              end
            end
          end
        end

        describe "and it raises SystemCallError" do
          it "is false" do
            @server.stub(:ready?, true) do
              @server.stub(:ssh_ip_address, "10.0.0.1") do
                raise_error = lambda { |_cmd, _options| raise SystemCallError.new("message, 0") }
                @server.stub(:ssh, raise_error) do
                  refute @server.sshable?
                end
              end
            end
          end

          it "does not increase SSH timeout" do
            @server.stub(:ready?, true) do
              @server.stub(:ssh_ip_address, "10.0.0.1") do
                raise_error = lambda { |_cmd, _options| raise SystemCallError.new("message, 0") }
                @server.stub(:ssh, raise_error) do
                  @server.sshable?
                  assert_equal @server.instance_variable_get(:@sshable_timeout), 8
                end
              end
            end
          end
        end

        describe "and ssh completes within the designated timeout" do
          it "is true" do
            @server.stub(:ready?, true) do
              @server.stub(:ssh_ip_address, "10.0.0.1") do
                @server.stub(:ssh, "datum") do
                  assert @server.sshable?
                end
              end
            end
          end
        end

        describe "when called successively" do
          describe "and ssh times out" do
            it "increases the timeout factor by 1.5" do
              @server.stub(:ready?, true) do
                @server.stub(:ssh_ip_address, "10.0.0.1") do
                  raises_timeout = lambda do |time|
                    assert(time == 8)
                    raise Timeout::Error.new
                  end
                  Timeout.stub(:timeout, raises_timeout) do
                    refute @server.sshable?
                  end

                  raises_timeout = lambda do |time|
                    assert_equal(12, time)
                    raise Timeout::Error.new
                  end
                  Timeout.stub(:timeout, raises_timeout) do
                    refute @server.sshable?
                  end
                end
              end
            end

            it "does not increase timeout beyond 60s" do
              @server.stub(:ready?, true) do
                @server.stub(:ssh_ip_address, "10.0.0.1") do
                  raises_timeout = lambda { |_time| raise Timeout::Error.new }
                  Timeout.stub(:timeout, raises_timeout) do
                    5.times { refute @server.sshable? }
                  end

                  raises_timeout = lambda do |time|
                    assert_equal(60, time)
                    raise Timeout::Error.new
                  end
                  Timeout.stub(:timeout, raises_timeout) do
                    refute @server.sshable?
                  end

                  raises_timeout = lambda do |time|
                    assert_equal(60, time)
                    raise Timeout::Error.new
                  end
                  Timeout.stub(:timeout, raises_timeout) do
                    refute @server.sshable?
                  end
                end
              end
            end

            describe "when ssh eventually succeeds" do
              it "resets the timeout to the initial value" do
                @server.stub(:ready?, true) do
                  @server.stub(:ssh_ip_address, "10.0.0.1") do
                    raises_timeout = lambda do |time|
                      assert(time == 8)
                      raise Timeout::Error.new
                    end
                    Timeout.stub(:timeout, raises_timeout) do
                      refute @server.sshable?
                    end

                    @server.stub(:ssh, "datum") do
                      assert @server.sshable?
                    end

                    raises_timeout = lambda do |time|
                      assert_equal(8, time)
                      raise Timeout::Error.new
                    end
                    Timeout.stub(:timeout, raises_timeout) do
                      refute @server.sshable?
                    end
                  end
                end
              end
            end

          end
        end

      end
    end

  end
end
