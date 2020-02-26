# frozen_string_literal: true

class Api::V1::Announcements::ReactionsController < Api::BaseController
  before_action -> { doorkeeper_authorize! :write, :'write:favourites' }
  before_action :require_user!

  before_action :set_announcement
  before_action :set_reaction, except: :update

  def update
    @announcement.announcement_reactions.create!(account: current_account, name: params[:id])
    render_empty
  end

  def destroy
    @reaction.destroy!
    render_empty
  end

  private

  def set_reaction
    @reaction = @announcement.announcement_reactions.where(account: current_account).find_by!(name: params[:id])
  end

  def set_announcement
    @announcement = Announcement.published.find(params[:announcement_id])
  end
end
