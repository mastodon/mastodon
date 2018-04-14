require 'spec_helper_integration'

describe Doorkeeper, 'configuration' do
  subject { Doorkeeper.configuration }

  describe 'resource_owner_authenticator' do
    it 'sets the block that is accessible via authenticate_resource_owner' do
      block = proc {}
      Doorkeeper.configure do
        orm DOORKEEPER_ORM
        resource_owner_authenticator(&block)
      end

      expect(subject.authenticate_resource_owner).to eq(block)
    end

    it 'prints warning message by default' do
      Doorkeeper.configure do
        orm DOORKEEPER_ORM
      end

      expect(Rails.logger).to receive(:warn).with(
        I18n.t('doorkeeper.errors.messages.resource_owner_authenticator_not_configured')
      )
      subject.authenticate_resource_owner.call(nil)
    end
  end

  describe 'resource_owner_from_credentials' do
    it 'sets the block that is accessible via authenticate_resource_owner' do
      block = proc {}
      Doorkeeper.configure do
        orm DOORKEEPER_ORM
        resource_owner_from_credentials(&block)
      end

      expect(subject.resource_owner_from_credentials).to eq(block)
    end

    it 'prints warning message by default' do
      Doorkeeper.configure do
        orm DOORKEEPER_ORM
      end

      expect(Rails.logger).to receive(:warn).with(
        I18n.t('doorkeeper.errors.messages.credential_flow_not_configured')
      )
      subject.resource_owner_from_credentials.call(nil)
    end
  end

  describe 'setup_orm_adapter' do
    it 'adds specific error message to NameError exception' do
      expect do
        Doorkeeper.configure { orm 'hibernate' }
      end.to raise_error(NameError, /ORM adapter not found \(hibernate\)/)
    end

    it 'does not change other exceptions' do
      allow_any_instance_of(String).to receive(:classify) { raise NoMethodError }

      expect do
        Doorkeeper.configure { orm 'hibernate' }
      end.to raise_error(NoMethodError, /ORM adapter not found \(hibernate\)/)
    end
  end

  describe 'admin_authenticator' do
    it 'sets the block that is accessible via authenticate_admin' do
      block = proc {}
      Doorkeeper.configure do
        orm DOORKEEPER_ORM
        admin_authenticator(&block)
      end

      expect(subject.authenticate_admin).to eq(block)
    end
  end

  describe 'access_token_expires_in' do
    it 'has 2 hours by default' do
      expect(subject.access_token_expires_in).to eq(2.hours)
    end

    it 'can change the value' do
      Doorkeeper.configure do
        orm DOORKEEPER_ORM
        access_token_expires_in 4.hours
      end
      expect(subject.access_token_expires_in).to eq(4.hours)
    end

    it 'can be set to nil' do
      Doorkeeper.configure do
        orm DOORKEEPER_ORM
        access_token_expires_in nil
      end

      expect(subject.access_token_expires_in).to be_nil
    end
  end

  describe 'scopes' do
    it 'has default scopes' do
      Doorkeeper.configure do
        orm DOORKEEPER_ORM
        default_scopes :public
      end

      expect(subject.default_scopes).to include('public')
    end

    it 'has optional scopes' do
      Doorkeeper.configure do
        orm DOORKEEPER_ORM
        optional_scopes :write, :update
      end

      expect(subject.optional_scopes).to include('write', 'update')
    end

    it 'has all scopes' do
      Doorkeeper.configure do
        orm DOORKEEPER_ORM
        default_scopes  :normal
        optional_scopes :admin
      end

      expect(subject.scopes).to include('normal', 'admin')
    end
  end

  describe 'use_refresh_token' do
    it 'is false by default' do
      expect(subject.refresh_token_enabled?).to be_falsey
    end

    it 'can change the value' do
      Doorkeeper.configure do
        orm DOORKEEPER_ORM
        use_refresh_token
      end

      expect(subject.refresh_token_enabled?).to be_truthy
    end

    it "does not includes 'refresh_token' in authorization_response_types" do
      expect(subject.token_grant_types).not_to include 'refresh_token'
    end

    context "is enabled" do
      before do
        Doorkeeper.configure {
          orm DOORKEEPER_ORM
          use_refresh_token
        }
      end

      it "includes 'refresh_token' in authorization_response_types" do
        expect(subject.token_grant_types).to include 'refresh_token'
      end
    end
  end

  describe 'client_credentials' do
    it 'has defaults order' do
      expect(subject.client_credentials_methods).to eq([:from_basic, :from_params])
    end

    it 'can change the value' do
      Doorkeeper.configure do
        orm DOORKEEPER_ORM
        client_credentials :from_digest, :from_params
      end

      expect(subject.client_credentials_methods).to eq([:from_digest, :from_params])
    end
  end

  describe 'force_ssl_in_redirect_uri' do
    it 'is true by default in non-development environments' do
      expect(subject.force_ssl_in_redirect_uri).to be_truthy
    end

    it 'can change the value' do
      Doorkeeper.configure do
        orm DOORKEEPER_ORM
        force_ssl_in_redirect_uri(false)
      end

      expect(subject.force_ssl_in_redirect_uri).to be_falsey
    end

    it 'can be a callable object' do
      block = proc { false }
      Doorkeeper.configure do
        orm DOORKEEPER_ORM
        force_ssl_in_redirect_uri(&block)
      end

      expect(subject.force_ssl_in_redirect_uri).to eq(block)
      expect(subject.force_ssl_in_redirect_uri.call).to be_falsey
    end
  end

  describe 'access_token_methods' do
    it 'has defaults order' do
      expect(subject.access_token_methods).to eq([:from_bearer_authorization, :from_access_token_param, :from_bearer_param])
    end

    it 'can change the value' do
      Doorkeeper.configure do
        orm DOORKEEPER_ORM
        access_token_methods :from_access_token_param, :from_bearer_param
      end

      expect(subject.access_token_methods).to eq([:from_access_token_param, :from_bearer_param])
    end
  end

  describe 'forbid_redirect_uri' do
    it 'is false by default' do
      expect(subject.forbid_redirect_uri.call(URI.parse('https://localhost'))).to be_falsey
    end

    it 'can be a callable object' do
      block = proc { true }
      Doorkeeper.configure do
        orm DOORKEEPER_ORM
        forbid_redirect_uri(&block)
      end

      expect(subject.forbid_redirect_uri).to eq(block)
      expect(subject.forbid_redirect_uri.call).to be_truthy
    end
  end

  describe 'enable_application_owner' do
    it 'is disabled by default' do
      expect(Doorkeeper.configuration.enable_application_owner?).not_to be_truthy
    end

    context 'when enabled without confirmation' do
      before do
        Doorkeeper.configure do
          orm DOORKEEPER_ORM
          enable_application_owner
        end
      end

      it 'adds support for application owner' do
        expect(Doorkeeper::Application.new).to respond_to :owner
      end

      it 'Doorkeeper.configuration.confirm_application_owner? returns false' do
        expect(Doorkeeper.configuration.confirm_application_owner?).not_to be_truthy
      end
    end

    context 'when enabled with confirmation set to true' do
      before do
        Doorkeeper.configure do
          orm DOORKEEPER_ORM
          enable_application_owner confirmation: true
        end
      end

      it 'adds support for application owner' do
        expect(Doorkeeper::Application.new).to respond_to :owner
      end

      it 'Doorkeeper.configuration.confirm_application_owner? returns true' do
        expect(Doorkeeper.configuration.confirm_application_owner?).to be_truthy
      end
    end
  end

  describe 'realm' do
    it 'is \'Doorkeeper\' by default' do
      expect(Doorkeeper.configuration.realm).to eq('Doorkeeper')
    end

    it 'can change the value' do
      Doorkeeper.configure do
        orm DOORKEEPER_ORM
        realm 'Example'
      end

      expect(subject.realm).to eq('Example')
    end
  end

  describe "grant_flows" do
    it "is set to all grant flows by default" do
      expect(Doorkeeper.configuration.grant_flows).
        to eq(%w[authorization_code client_credentials])
    end

    it "can change the value" do
      Doorkeeper.configure do
        orm DOORKEEPER_ORM
        grant_flows ['authorization_code', 'implicit']
      end

      expect(subject.grant_flows).to eq ['authorization_code', 'implicit']
    end

    context "when including 'authorization_code'" do
      before do
        Doorkeeper.configure do
          orm DOORKEEPER_ORM
          grant_flows ['authorization_code']
        end
      end

      it "includes 'code' in authorization_response_types" do
        expect(subject.authorization_response_types).to include 'code'
      end

      it "includes 'authorization_code' in token_grant_types" do
        expect(subject.token_grant_types).to include 'authorization_code'
      end
    end

    context "when including 'implicit'" do
      before do
        Doorkeeper.configure do
          orm DOORKEEPER_ORM
          grant_flows ['implicit']
        end
      end

      it "includes 'token' in authorization_response_types" do
        expect(subject.authorization_response_types).to include 'token'
      end
    end

    context "when including 'password'" do
      before do
        Doorkeeper.configure do
          orm DOORKEEPER_ORM
          grant_flows ['password']
        end
      end

      it "includes 'password' in token_grant_types" do
        expect(subject.token_grant_types).to include 'password'
      end
    end

    context "when including 'client_credentials'" do
      before do
        Doorkeeper.configure do
          orm DOORKEEPER_ORM
          grant_flows ['client_credentials']
        end
      end

      it "includes 'client_credentials' in token_grant_types" do
        expect(subject.token_grant_types).to include 'client_credentials'
      end
    end
  end

  it 'raises an exception when configuration is not set' do
    old_config = Doorkeeper.configuration
    Doorkeeper.module_eval do
      @config = nil
    end

    expect do
      Doorkeeper.configuration
    end.to raise_error Doorkeeper::MissingConfiguration

    Doorkeeper.module_eval do
      @config = old_config
    end
  end

  describe 'access_token_generator' do
    it 'is \'Doorkeeper::OAuth::Helpers::UniqueToken\' by default' do
      expect(Doorkeeper.configuration.access_token_generator).to(
        eq('Doorkeeper::OAuth::Helpers::UniqueToken')
      )
    end

    it 'can change the value' do
      Doorkeeper.configure do
        orm DOORKEEPER_ORM
        access_token_generator 'Example'
      end
      expect(subject.access_token_generator).to eq('Example')
    end
  end

  describe 'base_controller' do
    context 'default' do
      it { expect(Doorkeeper.configuration.base_controller).to eq('ActionController::Base') }
    end

    context 'custom' do
      before do
        Doorkeeper.configure do
          orm DOORKEEPER_ORM
          base_controller 'ApplicationController'
        end
      end

      it { expect(Doorkeeper.configuration.base_controller).to eq('ApplicationController') }
    end
  end

  if DOORKEEPER_ORM == :active_record
    describe 'active_record_options' do
      let(:models) { [Doorkeeper::AccessGrant, Doorkeeper::AccessToken, Doorkeeper::Application] }

      before do
        models.each do |model|
          allow(model).to receive(:establish_connection).and_return(true)
        end
      end

      it 'establishes connection for Doorkeeper models based on options' do
        models.each do |model|
          expect(model).to receive(:establish_connection)
        end

        Doorkeeper.configure do
          orm DOORKEEPER_ORM
          active_record_options(
            establish_connection: Rails.configuration.database_configuration[Rails.env]
          )
        end
      end
    end
  end
end
