# frozen_string_literal: true

class Api::PushController < ApiController
  def update
    response, status = process_push_request
    render plain: response, status: status
  end

  private

  def process_push_request
    case hub_mode
    when 'subscribe'
      Pubsubhubbub::SubscribeService.new.call(account_from_topic, hub_callback, hub_secret, hub_lease_seconds)
    when 'unsubscribe'
      Pubsubhubbub::UnsubscribeService.new.call(account_from_topic, hub_callback)
    else
      ["Unknown mode: #{hub_mode}", 422]
    end
  end

  def hub_mode
    params['hub.mode']
  end

  def hub_topic
    params['hub.topic']
  end

  def hub_callback
    params['hub.callback']
  end

  def hub_lease_seconds
    params['hub.lease_seconds']
  end

  def hub_secret
    params['hub.secret']
  end

  def account_from_topic
    if hub_topic.present? && local_domain? && account_feed_path?
      Account.find_local(hub_topic_params[:username])
    end
  end

  def hub_topic_params
    @_hub_topic_params ||= Rails.application.routes.recognize_path(hub_topic_uri.path)
  end

  def hub_topic_uri
    @_hub_topic_uri ||= Addressable::URI.parse(hub_topic).normalize
  end

  def local_domain?
    TagManager.instance.web_domain?(hub_topic_domain)
  end

  def hub_topic_domain
    hub_topic_uri.host + (hub_topic_uri.port ? ":#{hub_topic_uri.port}" : '')
  end

  def account_feed_path?
    hub_topic_params[:controller] == 'accounts' && hub_topic_params[:action] == 'show' && hub_topic_params[:format] == 'atom'
  end
end
