module AccessTokenRequestHelper
  def client_is_authorized(client, resource_owner, access_token_attributes = {})
    attributes = {
      application: client,
      resource_owner_id: resource_owner.id
    }.merge(access_token_attributes)
    FactoryBot.create(:access_token, attributes)
  end
end

RSpec.configuration.send :include, AccessTokenRequestHelper
