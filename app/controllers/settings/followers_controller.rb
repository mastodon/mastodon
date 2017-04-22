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

    domains.each do |domain|
      SoftBlockDomainFollowers.perform_async(current_account.id, domain)
    end

    redirect_to settings_followers_path, notice: I18n.t('followers.success', count: domains.size)
  end

  private

  def purge_params
    params.permit(select: [])
  end
end
