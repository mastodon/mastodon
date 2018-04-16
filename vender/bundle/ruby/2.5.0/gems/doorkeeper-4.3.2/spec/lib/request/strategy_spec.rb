require 'spec_helper'
require 'doorkeeper/request/strategy'

module Doorkeeper
  module Request
    describe Strategy do
      let(:server) { double }
      subject(:strategy) { Strategy.new(server) }

      describe :initialize do
        it "sets the server attribute" do
          expect(strategy.server).to eq server
        end
      end

      describe :request do
        it "requires an implementation" do
          expect { strategy.request }.to raise_exception NotImplementedError
        end
      end

      describe "a sample Strategy subclass" do
        let(:fake_request) { double }

        let(:strategy_class) do
          subclass = Class.new(Strategy) do
            class << self
              attr_accessor :fake_request
            end

            def request
              self.class.fake_request
            end
          end

          subclass.fake_request = fake_request
          subclass
        end

        subject(:strategy) { strategy_class.new(server) }

        it "provides a request implementation" do
          expect(strategy.request).to eq fake_request
        end

        it "authorizes the request" do
          expect(fake_request).to receive :authorize
          strategy.authorize
        end
      end
    end
  end
end
