require 'spec_helper_integration'

module Doorkeeper::OAuth
  describe BaseRequest do
    let(:access_token) do
      double :access_token,
        token:              "some-token",
        expires_in:         "3600",
        expires_in_seconds: "300",
        scopes_string:      "two scopes",
        refresh_token:      "some-refresh-token",
        token_type:         "bearer",
        created_at:         0
    end

    let(:client) { double :client, id: '1' }

    let(:scopes_array) { %w[public write] }

    let(:server) do
      double :server,
        access_token_expires_in: 100,
        custom_access_token_expires_in: ->(_) { nil },
        refresh_token_enabled?: false
    end

    subject do
      BaseRequest.new
    end

    describe "#authorize" do
      before do
        allow(subject).to receive(:access_token).and_return(access_token)
      end

      it "validates itself" do
        expect(subject).to receive(:validate).once
        subject.authorize
      end

      context "valid" do
        before do
          allow(subject).to receive(:valid?).and_return(true)
        end

        it "calls callback methods" do
          expect(subject).to receive(:before_successful_response).once
          expect(subject).to receive(:after_successful_response).once
          subject.authorize
        end

        it "returns a TokenResponse object" do
          result = subject.authorize

          expect(result).to be_an_instance_of(TokenResponse)
          expect(result.body).to eq(
            TokenResponse.new(access_token).body
          )
        end
      end

      context "invalid" do
        before do
          allow(subject).to receive(:valid?).and_return(false)
          allow(subject).to receive(:error).and_return("server_error")
          allow(subject).to receive(:state).and_return("hello")
        end

        it "returns an ErrorResponse object" do
          error_description = I18n.translate(
            "server_error",
            scope: %i[doorkeeper errors messages]
          )

          result = subject.authorize

          expect(result).to be_an_instance_of(ErrorResponse)

          expect(result.body).to eq(
            error: "server_error",
            error_description: error_description,
            state: "hello"
          )
        end
      end
    end

    describe "#default_scopes" do
      it "delegates to the server" do
        expect(subject).to receive(:server).and_return(server).once
        expect(server).to receive(:default_scopes).once

        subject.default_scopes
      end
    end

    describe "#find_or_create_access_token" do
      it "returns an instance of AccessToken" do
        result = subject.find_or_create_access_token(
          client,
          "1",
          "public",
          server
        )

        expect(result).to be_an_instance_of(Doorkeeper::AccessToken)
      end
    end

    describe "#scopes" do
      context "@original_scopes is present" do
        before do
          subject.instance_variable_set(:@original_scopes, "public write")
        end

        it "returns array of @original_scopes" do
          result = subject.scopes

          expect(result).to eq(scopes_array)
        end
      end

      context "@original_scopes is not present" do
        before do
          subject.instance_variable_set(:@original_scopes, "")
        end

        it "calls #default_scopes" do
          allow(subject).to receive(:server).and_return(server).once
          allow(server).to receive(:default_scopes).and_return(scopes_array).once

          result = subject.scopes

          expect(result).to eq(scopes_array)
        end
      end
    end

    describe "#valid?" do
      context "error is nil" do
        it "returns true" do
          allow(subject).to receive(:error).and_return(nil).once
          expect(subject.valid?).to eq(true)
        end
      end

      context "error is not nil" do
        it "returns false" do
          allow(subject).to receive(:error).and_return(Object.new).once
          expect(subject.valid?).to eq(false)
        end
      end
    end
  end
end
