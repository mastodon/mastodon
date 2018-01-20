# frozen_string_literal: true

class AuthorizeFollowsController < ApplicationController
  layout 'modal'

  before_action :authenticate_user!
  before_action :set_body_classes

  def show
    @account = located_account || render(:error)
  end

  def create
    @account = follow_attempt.try(:target_account)

    if @account.nil?
      render :error
    else
      render :success
    end
  rescue ActiveRecord::RecordNotFound, Mastodon::NotPermittedError
    render :error
  end

  private

  def follow_attempt
    FollowService.new.call(current_account, acct_without_prefix)
  end

  def located_account
    if acct_param_is_url?
      if TagManager.instance.local_url? acct_without_prefix
        account_from_local_url
      else
        account_from_remote_url
      end
    else
      account_webfinger
    end
  end

  def account_from_local_url
    TagManager.instance.url_to_resource(acct_without_prefix, Account)
  end

  def account_from_remote_url
    FetchRemoteAccountService.new.call(acct_without_prefix)
  end

  def account_webfinger
    ResolveRemoteAccountService.new.call(acct_without_prefix)
  end

  def acct_param_is_url?
    parsed_uri.path && %w(http https).include?(parsed_uri.scheme)
  end

  def parsed_uri
    Addressable::URI.parse(acct_without_prefix).normalize
  end

  def acct_without_prefix
    acct_params.gsub(/\Aacct:/, '')
  end

  def acct_params
    params.fetch(:acct, '')
  end

  def set_body_classes
    @body_classes = 'modal-layout'
  end
end
