# frozen_string_literal: true

require 'csv'
include RoutingHelper

class Settings::ExportsController < ApplicationController
  layout 'admin'

  before_action :authenticate_user!
  before_action :set_account

  def show
    @total_storage = current_account.media_attachments.sum(:file_file_size)
    @total_follows = current_account.following.count
    @total_blocks  = current_account.blocking.count
    @total_toots  = current_account.statuses.count
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

  def download_toots
    respond_to do |format|
      format.csv { render text: toots_to_csv(current_account.statuses) }
    end
  end

  private

  def set_account
    @account = current_user.account
  end

  def accounts_list_to_csv(list)
    CSV.generate do |csv|
      list.each do |account|
        csv << [(account.fully_qualified)]
      end
    end
  end

  def toots_to_csv(list)
    CSV.generate do |csv|
      csv << ["Created", "Account", "Visibility", "Text", "Favourites", "Boosts", "Replies", "Media"]
      list.each do |status|
        csv << [
          status.created_at,
          status.account.fully_qualified,
          status.visibility,
          status.text,
          status.favourites.count,
          status.reblogs.count,
          status.replies.count,
          status.media_attachments.map {
            |a| a.file_content_type + ';' + full_asset_url(a.file.url(:original, false))
          }.join(' '),
        ]
      end
    end
  end
end
