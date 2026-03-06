# frozen_string_literal: true

class Api::V1::ProfilesController < Api::BaseController
  before_action -> { doorkeeper_authorize! :profile, :read, :'read:accounts' }, except: [:update]
  before_action -> { doorkeeper_authorize! :write, :'write:accounts' }, only: [:update]
  before_action :require_user!

  def show
    @account = current_account
    render json: @account, serializer: REST::ProfileSerializer
  end

  def update
    @account = current_account
    UpdateAccountService.new.call(@account, account_params, raise_error: true)
    ActivityPub::UpdateDistributionWorker.perform_in(ActivityPub::UpdateDistributionWorker::DEBOUNCE_DELAY, @account.id)

    render json: @account, serializer: REST::ProfileSerializer
  rescue ActiveRecord::RecordInvalid => e
    render json: ValidationErrorFormatter.new(e).as_json, status: 422
  end

  def account_params
    params.permit(
      :display_name,
      :note,
      :avatar,
      :header,
      :locked,
      :bot,
      :discoverable,
      :hide_collections,
      :indexable,
      :show_media,
      :show_media_replies,
      :show_featured,
      attribution_domains: [],
      fields_attributes: [:name, :value]
    )
  end
end
