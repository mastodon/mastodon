# frozen_string_literal: true

class DirectoriesController < ApplicationController
  layout 'public'

  before_action :check_enabled
  before_action :set_instance_presenter
  before_action :set_tag, only: :show
  before_action :set_tags
  before_action :set_accounts

  def index
    render :index
  end

  def show
    render :index
  end

  private

  def check_enabled
    return not_found unless Setting.profile_directory
  end

  def set_tag
    @tag = Tag.discoverable.find_by!(name: params[:id].downcase)
  end

  def set_tags
    @tags = Tag.discoverable.limit(30).reject { |tag| tag.cached_sample_accounts.empty? }
  end

  def set_accounts
    @accounts = Account.discoverable.page(params[:page]).per(40).tap do |query|
      query.merge!(Account.tagged_with(@tag.id)) if @tag
    end
  end

  def set_instance_presenter
    @instance_presenter = InstancePresenter.new
  end
end
