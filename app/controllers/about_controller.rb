# frozen_string_literal: true

class AboutController < ApplicationController
  before_action :set_body_classes

  def index
    @description                  = Setting.site_description
    @open_registrations           = Setting.open_registrations
    @closed_registrations_message = Setting.closed_registrations_message

    @user = User.new
    @user.build_account
  end

  def more
    @description          = Setting.site_description
    @extended_description = Setting.site_extended_description
    @contact_account      = Account.find_local(Setting.site_contact_username)
    @contact_email        = Setting.site_contact_email
    @user_count           = Rails.cache.fetch('user_count')            { User.count }
    @status_count         = Rails.cache.fetch('local_status_count')    { Status.local.count }
    @domain_count         = Rails.cache.fetch('distinct_domain_count') { Account.distinct.count(:domain) }
  end

  def terms; end

  private

  def set_body_classes
    @body_classes = 'about-body'
  end
end
