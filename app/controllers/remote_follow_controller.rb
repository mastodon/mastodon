# frozen_string_literal: true

class RemoteFollowController < ApplicationController
  layout 'public'

  before_action :set_account
  before_action :check_account_suspension

  def new
    @remote_follow = RemoteFollow.new
    @remote_follow.acct = session[:remote_follow] if session.key?(:remote_follow)
  end

  def create
    @remote_follow = RemoteFollow.new(resource_params)

    if @remote_follow.valid?
      resource          = Goldfinger.finger("acct:#{@remote_follow.acct}")
      redirect_url_link = resource&.link('http://ostatus.org/schema/1.0/subscribe')

      if redirect_url_link.nil? || redirect_url_link.template.nil?
        @remote_follow.errors.add(:acct, I18n.t('remote_follow.missing_resource'))
        render(:new) && return
      end

      session[:remote_follow] = @remote_follow.acct

      redirect_to Addressable::Template.new(redirect_url_link.template).expand(uri: @account.to_webfinger_s).to_s
    else
      render :new
    end
  rescue Goldfinger::Error
    @remote_follow.errors.add(:acct, I18n.t('remote_follow.missing_resource'))
    render :new
  end

  private

  def resource_params
    params.require(:remote_follow).permit(:acct)
  end

  def set_account
    @account = Account.find_local!(params[:account_username])
  end

  def check_account_suspension
    head 410 if @account.suspended?
  end
end
