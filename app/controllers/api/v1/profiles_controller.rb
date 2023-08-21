# frozen_string_literal: true

class Api::V1::ProfilesController < Api::BaseController
  before_action -> { doorkeeper_authorize! :write, :'write:accounts' }
  before_action :require_user!
  before_action :set_image
  before_action :validate_image_param

  def destroy
    @account = current_account
    UpdateAccountService.new.call(@account, { @image => nil }, raise_error: true)
    ActivityPub::UpdateDistributionWorker.perform_async(@account.id)
    render json: @account, serializer: REST::CredentialAccountSerializer
  end

  private

  def set_image
    @image = params[:image]
  end

  def validate_image_param
    raise(Mastodon::InvalidParameterError, 'Image must be either "avatar" or "header"') unless valid_image?
  end

  def valid_image?
    %w(avatar header).include?(@image)
  end
end
