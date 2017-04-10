# frozen_string_literal: true

require 'csv'

class Settings::ExportsController < ApplicationController
  layout 'admin'

  before_action :authenticate_user!
  before_action :set_account

  def show
    @total_storage = current_account.media_attachments.sum(:file_file_size)
    @total_follows = current_account.following.count
    @total_blocks  = current_account.blocking.count
  end

  def download_following_list
    @accounts = current_account.following

    respond_to do |format|
      format.csv { render text: accounts_list_to_csv(@accounts) }
    end
  end

  def download_blocking_list
    @accounts = current_account.blocking

    respond_to do |format|
      format.csv { render text: accounts_list_to_csv(@accounts) }
    end
  end

  private

  def set_account
    @account = current_user.account
  end

  def accounts_list_to_csv(list)
    CSV.generate do |csv|
      list.each do |account|
        csv << [(account.local? ? account.local_username_and_domain : account.acct)]
      end
    end
  end
end
