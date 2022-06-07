# frozen_string_literal: true

class InstanceActorsController < ApplicationController
  include AccountControllerConcern

  skip_before_action :check_account_confirmation
  skip_around_action :set_locale

  def show
    expires_in 10.minutes, public: true
    render json: @account, content_type: 'application/activity+json', serializer: ActivityPub::ActorSerializer, adapter: ActivityPub::Adapter, fields: restrict_fields_to
  end

  private

  def set_account
    @account = Account.representative
  end

  def restrict_fields_to
    %i(id type preferred_username inbox outbox public_key endpoints url manually_approves_followers)
  end
end
