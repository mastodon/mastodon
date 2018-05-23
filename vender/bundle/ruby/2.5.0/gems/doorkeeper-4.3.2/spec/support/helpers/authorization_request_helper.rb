module AuthorizationRequestHelper
  def resource_owner_is_authenticated(resource_owner = nil)
    resource_owner ||= User.create!(name: 'Joe', password: 'sekret')
    Doorkeeper.configuration.instance_variable_set(:@authenticate_resource_owner, proc { resource_owner })
  end

  def resource_owner_is_not_authenticated
    Doorkeeper.configuration.instance_variable_set(:@authenticate_resource_owner, proc { redirect_to('/sign_in') })
  end

  def default_scopes_exist(*scopes)
    Doorkeeper.configuration.instance_variable_set(:@default_scopes, Doorkeeper::OAuth::Scopes.from_array(scopes))
  end

  def optional_scopes_exist(*scopes)
    Doorkeeper.configuration.instance_variable_set(:@optional_scopes, Doorkeeper::OAuth::Scopes.from_array(scopes))
  end

  def client_should_be_authorized(client)
    expect(client.access_grants.size).to eq(1)
  end

  def client_should_not_be_authorized(client)
    expect(client.size).to eq(0)
  end

  def i_should_be_on_client_callback(client)
    expect(client.redirect_uri).to eq("#{current_uri.scheme}://#{current_uri.host}#{current_uri.path}")
  end

  def allowing_forgery_protection(&block)
    _original_value = ActionController::Base.allow_forgery_protection
    ActionController::Base.allow_forgery_protection = true

    block.call
  ensure
    ActionController::Base.allow_forgery_protection = _original_value
  end
end

RSpec.configuration.send :include, AuthorizationRequestHelper
