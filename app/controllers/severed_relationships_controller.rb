# frozen_string_literal: true

class SeveredRelationshipsController < ApplicationController
  layout 'admin'

  before_action :authenticate_user!
  before_action :set_cache_headers

  before_action :set_event, only: [:following, :followers]

  def index
    @events = AccountRelationshipSeveranceEvent.where(account: current_account)
  end

  def following
    respond_to do |format|
      format.csv { send_data following_data, filename: "following-#{@event.target_name}-#{@event.created_at.to_date.iso8601}.csv" }
    end
  end

  def followers
    respond_to do |format|
      format.csv { send_data followers_data, filename: "followers-#{@event.target_name}-#{@event.created_at.to_date.iso8601}.csv" }
    end
  end

  private

  def set_event
    @event = AccountRelationshipSeveranceEvent.find(params[:id])
  end

  def following_data
    CSV.generate(headers: ['Account address', 'Show boosts', 'Notify on new posts', 'Languages'], write_headers: true) do |csv|
      @event.severed_relationships.active.about_local_account(current_account).includes(:remote_account).reorder(id: :desc).each do |follow|
        csv << [acct(follow.target_account), follow.show_reblogs, follow.notify, follow.languages&.join(', ')]
      end
    end
  end

  def followers_data
    CSV.generate(headers: ['Account address'], write_headers: true) do |csv|
      @event.severed_relationships.passive.about_local_account(current_account).includes(:remote_account).reorder(id: :desc).each do |follow|
        csv << [acct(follow.account)]
      end
    end
  end

  def acct(account)
    account.local? ? account.local_username_and_domain : account.acct
  end

  def set_cache_headers
    response.cache_control.replace(private: true, no_store: true)
  end
end
