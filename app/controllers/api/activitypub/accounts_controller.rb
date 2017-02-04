# frozen_string_literal: true

class Api::Activitypub::AccountsController < ApiController
  before_action -> { doorkeeper_authorize! :read }, except: [:show]
  before_action :require_user!, except: [:show]
  before_action :set_account, except: [:verify_credentials, :suggestions, :search]

  respond_to :'application/activity+json'
  respond_to :'application/ld+json; profile="https://www.w3.org/ns/activitystreams#"'

  def show
    render content_type: :'application/ld+json; profile="https://www.w3.org/ns/activitystreams#"'
  end

  private

  def set_account
    @account = Account.find(params[:id])
  end
end
