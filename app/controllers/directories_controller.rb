# frozen_string_literal: true

class DirectoriesController < ApplicationController
  layout 'public'

  before_action :authenticate_user!, if: :whitelist_mode?
  before_action :require_enabled!
  before_action :set_instance_presenter
  before_action :set_accounts
  before_action :set_pack

  skip_before_action :require_functional!, unless: :whitelist_mode?

  def index
    render :index
  end

  private

  def set_pack
    use_pack 'share'
  end

  def require_enabled!
    return not_found unless Setting.profile_directory
  end

  def set_accounts
    @accounts = Account.local.discoverable.by_recent_status.page(params[:page]).per(20).tap do |query|
      query.merge!(Account.not_excluded_by_account(current_account)) if current_account
    end
  end

  def set_instance_presenter
    @instance_presenter = InstancePresenter.new
  end
end
