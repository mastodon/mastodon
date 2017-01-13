# frozen_string_literal: true

class AboutController < ApplicationController
  before_action :set_body_classes

  def index
    @description = Setting.site_description
  end

  def more
    @extended_description = Setting.site_extended_description
    @contact_account      = Account.find_local(Setting.site_contact_username)
    @contact_email        = Setting.site_contact_email
  end

  def terms; end

  private

  def set_body_classes
    @body_classes = 'about-body'
  end
end
