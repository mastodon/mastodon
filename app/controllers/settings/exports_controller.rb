# frozen_string_literal: true

class Settings::ExportsController < ApplicationController
  layout 'admin'

  before_action :authenticate_user!

  def show
    @total_storage = current_account.media_attachments.sum(:file_file_size)
    @total_follows = current_account.following.count
    @total_blocks  = current_account.blocking.count
  end

  def download_following_list
    export_data = Export.new(current_account.following).to_csv

    respond_to do |format|
      format.csv { send_data export_data, filename: 'following.csv' }
    end
  end

  def download_blocking_list
    export_data = Export.new(current_account.blocking).to_csv

    respond_to do |format|
      format.csv { send_data export_data, filename: 'blocking.csv' }
    end
  end
end
