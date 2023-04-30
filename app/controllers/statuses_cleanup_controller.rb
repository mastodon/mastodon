# frozen_string_literal: true

class StatusesCleanupController < ApplicationController
  layout 'admin'

  before_action :authenticate_user!
  before_action :set_policy
  before_action :set_body_classes
  before_action :set_pack
  before_action :set_cache_headers

  def show; end

  def update
    if @policy.update(resource_params)
      redirect_to statuses_cleanup_path, notice: I18n.t('generic.changes_saved_msg')
    else
      render action: :show
    end
  rescue ActionController::ParameterMissing
    # Do nothing
  end

  def require_functional!
    redirect_to edit_user_registration_path unless current_user.functional_or_moved?
  end

  private

  def set_pack
    use_pack 'settings'
  end

  def set_policy
    @policy = current_account.statuses_cleanup_policy || current_account.build_statuses_cleanup_policy(enabled: false)
  end

  def resource_params
    params.require(:account_statuses_cleanup_policy).permit(:enabled, :min_status_age, :keep_direct, :keep_pinned, :keep_polls, :keep_media, :keep_self_fav, :keep_self_bookmark, :min_favs, :min_reblogs)
  end

  def set_body_classes
    @body_classes = 'admin'
  end

  def set_cache_headers
    response.cache_control.replace(private: true, no_store: true)
  end
end
