# frozen_string_literal: true

class AboutController < ApplicationController
  before_action :set_body_classes
  before_action :set_site_presenter, only: [:show, :more]

  def show; end

  def more; end

  def terms; end

  private

  def new_user
    User.new.tap(&:build_account)
  end
  helper_method :new_user

  def set_site_presenter
    @site = SitePresenter.new
  end

  def set_body_classes
    @body_classes = 'about-body'
  end
end
