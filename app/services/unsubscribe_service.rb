# frozen_string_literal: true

class UnsubscribeService < BaseService
  def call(account)
    return if account.hub_url.blank?

    @account = account

    begin
      @response = build_request.perform

      Rails.logger.debug "PuSH unsubscribe for #{@account.acct} failed: #{@response.status}" unless @response.status.success?
      @response.connection&.close
    rescue HTTP::Error, OpenSSL::SSL::SSLError => e
      Rails.logger.debug "PuSH unsubscribe for #{@account.acct} failed: #{e}"
    end

    @account.secret = ''
    @account.subscription_expires_at = nil
    @account.save!
  end

  private

  def build_request
    Request.new(:post, @account.hub_url, form: subscription_params)
  end

  def subscription_params
    {
      'hub.topic': @account.remote_url,
      'hub.mode': 'unsubscribe',
      'hub.callback': api_subscription_url(@account.id),
      'hub.verify': 'async',
    }
  end
end
