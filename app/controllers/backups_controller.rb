# frozen_string_literal: true

class BackupsController < ApplicationController
  include RoutingHelper

  skip_before_action :require_functional!

  before_action :authenticate_user!
  before_action :set_backup

  def download
    case Paperclip::Attachment.default_options[:storage]
    when :s3, :azure
      redirect_to @backup.dump.expiring_url(10), allow_other_host: true
    when :fog
      if Paperclip::Attachment.default_options.dig(:fog_credentials, :openstack_temp_url_key).present?
        redirect_to @backup.dump.expiring_url(Time.now.utc + 10), allow_other_host: true
      else
        redirect_to full_asset_url(@backup.dump.url), allow_other_host: true
      end
    when :filesystem
      redirect_to full_asset_url(@backup.dump.url), allow_other_host: true
    end
  end

  private

  def set_backup
    @backup = current_user.backups.find(params[:id])
  end
end
