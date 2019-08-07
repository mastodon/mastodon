# frozen_string_literal: true

class DirectoriesController < ApplicationController
  layout 'public'

  before_action :authenticate_user!, if: :whitelist_mode?
  before_action :require_enabled!
  before_action :set_instance_presenter
  before_action :set_tag, only: :show
  before_action :set_tags
  before_action :set_accounts
  before_action :set_pack

  def index
    render :index
  end

  def show
    render :index
  end

  private

  def set_pack
    use_pack 'share'
  end

  def require_enabled!
    return not_found unless Setting.profile_directory
  end

  def set_tag
    @tag = Tag.discoverable.find_normalized!(params[:id])
  end

  def set_tags
    @tags = Tag.discoverable.limit(30).reject { |tag| tag.cached_sample_accounts.empty? }
  end

  def set_accounts
    @accounts = Account.discoverable.by_recent_status.page(params[:page]).per(40).tap do |query|
      query.merge!(Account.tagged_with(@tag.id)) if @tag
    end
  end

  def set_instance_presenter
    @instance_presenter = InstancePresenter.new
  end
end
