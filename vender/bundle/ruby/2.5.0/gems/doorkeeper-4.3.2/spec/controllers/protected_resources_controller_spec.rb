require 'spec_helper_integration'

module ControllerActions
  def index
    render plain: 'index'
  end

  def show
    render plain: 'show'
  end

  def doorkeeper_unauthorized_render_options(*); end

  def doorkeeper_forbidden_render_options(*); end
end

describe 'doorkeeper authorize filter' do
  context 'accepts token code specified as' do
    controller do
      before_action :doorkeeper_authorize!

      def index
        render plain: 'index'
      end
    end

    let(:token_string) { '1A2BC3' }
    let(:token) do
      double(Doorkeeper::AccessToken,
             acceptable?: true, previous_refresh_token: "",
             revoke_previous_refresh_token!: true)
    end

    it 'access_token param' do
      expect(Doorkeeper::AccessToken).to receive(:by_token).with(token_string).and_return(token)
      get :index, access_token: token_string
    end

    it 'bearer_token param' do
      expect(Doorkeeper::AccessToken).to receive(:by_token).with(token_string).and_return(token)
      get :index, bearer_token: token_string
    end

    it 'Authorization header' do
      expect(Doorkeeper::AccessToken).to receive(:by_token).with(token_string).and_return(token)
      request.env['HTTP_AUTHORIZATION'] = "Bearer #{token_string}"
      get :index
    end

    it 'different kind of Authorization header' do
      expect(Doorkeeper::AccessToken).not_to receive(:by_token)
      request.env['HTTP_AUTHORIZATION'] = "MAC #{token_string}"
      get :index
    end

    it 'does not change Authorization header value' do
      expect(Doorkeeper::AccessToken).to receive(:by_token).exactly(2).times.and_return(token)
      request.env['HTTP_AUTHORIZATION'] = "Bearer #{token_string}"
      get :index
      controller.send(:remove_instance_variable, :@_doorkeeper_token)
      get :index
    end
  end

  context 'defined for all actions' do
    controller do
      before_action :doorkeeper_authorize!

      include ControllerActions
    end

    context 'with valid token', token: :valid do
      it 'allows into index action' do
        get :index, access_token: token_string
        expect(response).to be_successful
      end

      it 'allows into show action' do
        get :show, id: '4', access_token: token_string
        expect(response).to be_successful
      end
    end

    context 'with invalid token', token: :invalid do
      it 'does not allow into index action' do
        get :index, access_token: token_string
        expect(response.status).to eq 401
        expect(response.header['WWW-Authenticate']).to match(/^Bearer/)
      end

      it 'does not allow into show action' do
        get :show, id: '4', access_token: token_string
        expect(response.status).to eq 401
        expect(response.header['WWW-Authenticate']).to match(/^Bearer/)
      end
    end
  end

  context 'defined with scopes' do
    controller do
      before_action -> { doorkeeper_authorize! :write }

      include ControllerActions
    end

    let(:token_string) { '1A2DUWE' }

    it 'allows if the token has particular scopes' do
      token = double(Doorkeeper::AccessToken,
                     accessible?: true, scopes: %w[write public],
                     previous_refresh_token: "",
                     revoke_previous_refresh_token!: true)
      expect(token).to receive(:acceptable?).with([:write]).and_return(true)
      expect(
        Doorkeeper::AccessToken
      ).to receive(:by_token).with(token_string).and_return(token)

      get :index, access_token: token_string
      expect(response).to be_successful
    end

    it 'does not allow if the token does not include given scope' do
      token = double(Doorkeeper::AccessToken,
                     accessible?: true, scopes: ['public'], revoked?: false,
                     expired?: false, previous_refresh_token: "",
                     revoke_previous_refresh_token!: true)
      expect(
        Doorkeeper::AccessToken
      ).to receive(:by_token).with(token_string).and_return(token)
      expect(token).to receive(:acceptable?).with([:write]).and_return(false)

      get :index, access_token: token_string
      expect(response.status).to eq 403
      expect(response.header).to_not include('WWW-Authenticate')
    end
  end

  context 'when custom unauthorized render options are configured' do
    controller do
      before_action :doorkeeper_authorize!

      include ControllerActions
    end

    context 'with a JSON custom render', token: :invalid do
      before do
        module ControllerActions
          remove_method :doorkeeper_unauthorized_render_options

          def doorkeeper_unauthorized_render_options(error: nil)
            { json: ActiveSupport::JSON.encode(error_message: error.description) }
          end
        end
      end

      after do
        module ControllerActions
          remove_method :doorkeeper_unauthorized_render_options

          def doorkeeper_unauthorized_render_options(error: nil)
          end
        end
      end

      it 'it renders a custom JSON response', token: :invalid do
        get :index, access_token: token_string
        expect(response.status).to eq 401
        expect(response.content_type).to eq('application/json')
        expect(response.header['WWW-Authenticate']).to match(/^Bearer/)

        expect(json_response).not_to be_nil
        expect(json_response['error_message']).to match('token is invalid')
      end
    end

    context 'with a text custom render', token: :invalid do
      before do
        module ControllerActions
          remove_method :doorkeeper_unauthorized_render_options

          def doorkeeper_unauthorized_render_options(**)
            { plain: 'Unauthorized' }
          end
        end
      end

      after do
        module ControllerActions
          remove_method :doorkeeper_unauthorized_render_options

          def doorkeeper_unauthorized_render_options(error: nil); end
        end
      end

      it 'it renders a custom text response', token: :invalid do
        get :index, access_token: token_string
        expect(response.status).to eq 401
        expect(response.content_type).to eq('text/plain')
        expect(response.header['WWW-Authenticate']).to match(/^Bearer/)
        expect(response.body).to eq('Unauthorized')
      end
    end
  end

  context 'when custom forbidden render options are configured' do
    before do
      expect(Doorkeeper::AccessToken).to receive(:by_token).with(token_string).and_return(token)
      expect(token).to receive(:acceptable?).with([:write]).and_return(false)
    end

    after do
      module ControllerActions
        remove_method :doorkeeper_forbidden_render_options

        def doorkeeper_forbidden_render_options(*); end
      end
    end

    controller do
      before_action -> { doorkeeper_authorize! :write }

      include ControllerActions
    end

    let(:token) do
      double(Doorkeeper::AccessToken,
             accessible?: true, scopes: ['public'], revoked?: false,
             expired?: false, previous_refresh_token: "",
             revoke_previous_refresh_token!: true)
    end

    let(:token_string) { '1A2DUWE' }

    context 'with a JSON custom render' do
      before do
        module ControllerActions
          remove_method :doorkeeper_forbidden_render_options

          def doorkeeper_forbidden_render_options(*)
            { json: { error_message: 'Forbidden' } }
          end
        end
      end

      it 'renders a custom JSON response' do
        get :index, access_token: token_string
        expect(response.header).to_not include('WWW-Authenticate')
        expect(response.content_type).to eq('application/json')
        expect(response.status).to eq 403

        expect(json_response).not_to be_nil
        expect(json_response['error_message']).to match('Forbidden')
      end
    end

    context 'with a status and JSON custom render' do
      before do
        module ControllerActions
          remove_method :doorkeeper_forbidden_render_options
          def doorkeeper_forbidden_render_options(*)
            { json: { error_message: 'Not Found' },
              respond_not_found_when_forbidden: true }
          end
        end
      end

      it 'overrides the default status code' do
        get :index, access_token: token_string
        expect(response.status).to eq 404
      end
    end

    context 'with a text custom render' do
      before do
        module ControllerActions
          remove_method :doorkeeper_forbidden_render_options

          def doorkeeper_forbidden_render_options(*)
            { plain: 'Forbidden' }
          end
        end
      end

      it 'renders a custom status code and text response' do
        get :index, access_token: token_string
        expect(response.header).to_not include('WWW-Authenticate')
        expect(response.status).to eq 403
        expect(response.body).to eq('Forbidden')
      end
    end

    context 'with a status and text custom render' do
      before do
        module ControllerActions
          remove_method :doorkeeper_forbidden_render_options

          def doorkeeper_forbidden_render_options(*)
            { respond_not_found_when_forbidden: true, plain: 'Not Found' }
          end
        end
      end

      it 'overrides the default status code' do
        get :index, access_token: token_string
        expect(response.status).to eq 404
      end
    end
  end
end
