# frozen_string_literal: true

class Settings::FollowersController < ApplicationController
  layout 'admin'

  before_action :authenticate_user!

  def show
    @account = current_account
    @domains = current_account.followers.reorder(nil).group('accounts.domain').select('accounts.domain, count(accounts.*) as accounts_from_domain')
  end

  def purge
    domains = purge_params[:select] || []
    total   = 0

    domains.each do |domain|
      current_account.followers.where(domain: domain).find_each do |follower|
        BlockService.new.call(current_account, follower)
        UnblockService.new.call(current_account, follower)
        total += 1
      end
    end

    redirect_to settings_followers_path, notice: I18n.t('followers.success', count: total)
  end

  private

  def purge_params
    params.permit(select: [])
  end
end
