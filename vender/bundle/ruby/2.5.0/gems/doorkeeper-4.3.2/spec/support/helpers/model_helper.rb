module ModelHelper
  def client_exists(client_attributes = {})
    @client = FactoryBot.create(:application, client_attributes)
  end

  def create_resource_owner
    @resource_owner = User.create!(name: 'Joe', password: 'sekret')
  end

  def authorization_code_exists(options = {})
    @authorization = FactoryBot.create(:access_grant, options)
  end

  def access_grant_should_exist_for(client, resource_owner)
    grant = Doorkeeper::AccessGrant.first

    expect(grant.application).to have_attributes(id: client.id).
      and(be_instance_of(Doorkeeper::Application))

    expect(grant.resource_owner_id).to eq(resource_owner.id)
  end

  def access_token_should_exist_for(client, resource_owner)
    token = Doorkeeper::AccessToken.first

    expect(token.application).to have_attributes(id: client.id).
      and(be_instance_of(Doorkeeper::Application))

    expect(token.resource_owner_id).to eq(resource_owner.id)
  end

  def access_grant_should_not_exist
    expect(Doorkeeper::AccessGrant.all).to be_empty
  end

  def access_token_should_not_exist
    expect(Doorkeeper::AccessToken.all).to be_empty
  end

  def access_grant_should_have_scopes(*args)
    grant = Doorkeeper::AccessGrant.first
    expect(grant.scopes).to eq(Doorkeeper::OAuth::Scopes.from_array(args))
  end

  def access_token_should_have_scopes(*args)
    grant = Doorkeeper::AccessToken.last
    expect(grant.scopes).to eq(Doorkeeper::OAuth::Scopes.from_array(args))
  end

  def uniqueness_error
    case DOORKEEPER_ORM
    when :active_record
      ActiveRecord::RecordNotUnique
    when :sequel
      error_classes = [Sequel::UniqueConstraintViolation, Sequel::ValidationFailed]
      proc { |error| expect(error.class).to be_in(error_classes) }
    when :mongo_mapper
      error_classes = [MongoMapper::DocumentNotValid, Mongo::OperationFailure]
      proc { |error| expect(error.class).to be_in(error_classes) }
    when /mongoid/
      error_classes = [Mongoid::Errors::Validations]
      error_classes << Moped::Errors::OperationFailure if defined?(::Moped) # Mongoid 4
      error_classes << Mongo::Error::OperationFailure if defined?(::Mongo) # Mongoid 5

      proc { |error| expect(error.class).to be_in(error_classes) }
    else
      raise "'#{DOORKEEPER_ORM}' ORM is not supported!"
    end
  end
end

RSpec.configuration.send :include, ModelHelper
