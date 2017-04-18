# frozen_string_literal: true

class Api::PushController < ApiController
  def update
    mode          = params['hub.mode']
    topic         = params['hub.topic']
    callback      = params['hub.callback']
    lease_seconds = params['hub.lease_seconds']
    secret        = params['hub.secret']

    case mode
    when 'subscribe'
      response, status = Pubsubhubbub::SubscribeService.new.call(topic_to_account(topic), callback, secret, lease_seconds)
    when 'unsubscribe'
      response, status = Pubsubhubbub::UnsubscribeService.new.call(topic_to_account(topic), callback)
    else
      response = "Unknown mode: #{mode}"
      status   = 422
    end

    render plain: response, status: status
  end

  private

  def topic_to_account(topic_url)
    return if topic_url.blank?

    uri    = Addressable::URI.parse(topic_url)
    params = Rails.application.routes.recognize_path(uri.path)
    domain = uri.host + (uri.port ? ":#{uri.port}" : '')

    return unless TagManager.instance.web_domain?(domain) && params[:controller] == 'accounts' && params[:action] == 'show' && params[:format] == 'atom'

    Account.find_local(params[:username])
  end
end
