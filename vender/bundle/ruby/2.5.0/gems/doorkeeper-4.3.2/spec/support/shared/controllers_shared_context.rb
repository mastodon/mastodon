shared_context 'valid token', token: :valid do
  let(:token_string) { '1A2B3C4D' }

  let :token do
    double(Doorkeeper::AccessToken,
           accessible?: true, includes_scope?: true, acceptable?: true,
           previous_refresh_token: "", revoke_previous_refresh_token!: true)
  end

  before :each do
    allow(
      Doorkeeper::AccessToken
    ).to receive(:by_token).with(token_string).and_return(token)
  end
end

shared_context 'invalid token', token: :invalid do
  let(:token_string) { '1A2B3C4D' }

  let :token do
    double(Doorkeeper::AccessToken,
           accessible?: false, revoked?: false, expired?: false,
           includes_scope?: false, acceptable?: false,
           previous_refresh_token: "", revoke_previous_refresh_token!: true)
  end

  before :each do
    allow(
      Doorkeeper::AccessToken
    ).to receive(:by_token).with(token_string).and_return(token)
  end
end

shared_context 'authenticated resource owner' do
  before do
    user = double(:resource, id: 1)
    allow(Doorkeeper.configuration).to receive(:authenticate_resource_owner) { proc { user } }
  end
end

shared_context 'not authenticated resource owner' do
  before do
    allow(Doorkeeper.configuration).to receive(:authenticate_resource_owner) { proc { redirect_to '/' } }
  end
end

shared_context 'valid authorization request' do
  let :authorization do
    double(:authorization, valid?: true, authorize: true, success_redirect_uri: 'http://something.com/cb?code=token')
  end

  before do
    allow(controller).to receive(:authorization) { authorization }
  end
end

shared_context 'invalid authorization request' do
  let :authorization do
    double(:authorization, valid?: false, authorize: false, redirect_on_error?: false)
  end

  before do
    allow(controller).to receive(:authorization) { authorization }
  end
end
