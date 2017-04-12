# frozen_string_literal: true

class Settings::ExportsController < ApplicationController
  layout 'admin'

  before_action :authenticate_user!

  def show
    @total_storage = current_account.media_attachments.sum(:file_file_size)
    @total_follows = current_account.following.count
    @total_blocks  = current_account.blocking.count
    @total_mutes = current_account.muting.count
  end
end
