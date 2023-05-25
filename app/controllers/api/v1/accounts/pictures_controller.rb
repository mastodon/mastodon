# frozen_string_literal: true

class Api::V1::Accounts::PicturesController < Api::BaseController
  before_action -> { doorkeeper_authorize! :write, :'write:accounts' }
  before_action :require_user!
  before_action :set_picture
  before_action :validate_picture_param

  def destroy
    @account = current_account
    UpdateAccountService.new.call(@account, { @picture => nil, "#{@picture}_remote_url" => '' }, raise_error: true)
    ActivityPub::UpdateDistributionWorker.perform_async(@account.id)
    render json: @account, serializer: REST::CredentialAccountSerializer
  end

  private

  def set_picture
    @picture = params[:picture]
  end

  def validate_picture_param
    raise(Mastodon::InvalidParameterError, 'Picture must be either "avatar" or "header"') unless valid_picture?
  end

  def valid_picture?
    %w(avatar header).include?(@picture)
  end
end
