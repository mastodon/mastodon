# frozen_string_literal: true

class BackupsController < ApplicationController
  include RoutingHelper

  skip_before_action :require_functional!

  before_action :authenticate_user!
  before_action :set_backup

  def download
    case Paperclip::Attachment.default_options[:storage]
    when :s3
      redirect_to @backup.dump.expiring_url(10)
    when :fog
      if Paperclip::Attachment.default_options.dig(:storage, :fog_credentials, :openstack_temp_url_key).present?
        redirect_to @backup.dump.expiring_url(Time.now.utc + 10)
      else
        redirect_to full_asset_url(@backup.dump.url)
      end
    when :filesystem
      redirect_to full_asset_url(@backup.dump.url)
    end
  end

  private

  def set_backup
    @backup = current_user.backups.find(params[:id])
  end
end
