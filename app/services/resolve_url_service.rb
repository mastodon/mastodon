# frozen_string_literal: true

class ResolveURLService < BaseService
  include JsonLdHelper
  include Authorization

  def call(url, on_behalf_of: nil)
    @url          = url
    @on_behalf_of = on_behalf_of

    if local_url?
      process_local_url
    elsif !fetched_resource.nil?
      process_url
    elsif @on_behalf_of.present?
      process_url_from_db
    end
  end

  private

  def process_url
    if equals_or_includes_any?(type, ActivityPub::FetchRemoteAccountService::SUPPORTED_TYPES)
      ActivityPub::FetchRemoteAccountService.new.call(resource_url, prefetched_body: body)
    elsif equals_or_includes_any?(type, ActivityPub::Activity::Create::SUPPORTED_TYPES + ActivityPub::Activity::Create::CONVERTED_TYPES)
      status = FetchRemoteStatusService.new.call(resource_url, body)
      authorize_with @on_behalf_of, status, :show? unless status.nil?
      status
    end
  end

  def process_url_from_db
    # It may happen that the resource is a private toot, and thus not fetchable,
    # but we can return the toot if we already know about it.
    status = Status.find_by(uri: @url) || Status.find_by(url: @url)
    authorize_with @on_behalf_of, status, :show? unless status.nil?
    status
  rescue Mastodon::NotPermittedError
    nil
  end

  def fetched_resource
    @fetched_resource ||= FetchResourceService.new.call(@url)
  end

  def resource_url
    fetched_resource.first
  end

  def body
    fetched_resource.second[:prefetched_body]
  end

  def type
    json_data['type']
  end

  def json_data
    @json_data ||= body_to_json(body)
  end

  def local_url?
    TagManager.instance.local_url?(@url)
  end

  def process_local_url
    recognized_params = Rails.application.routes.recognize_path(@url)

    return unless recognized_params[:action] == 'show'

    if recognized_params[:controller] == 'statuses'
      status = Status.find_by(id: recognized_params[:id])
      check_local_status(status)
    elsif recognized_params[:controller] == 'accounts'
      Account.find_local(recognized_params[:username])
    end
  end

  def check_local_status(status)
    return if status.nil?

    authorize_with @on_behalf_of, status, :show?
    status
  rescue Mastodon::NotPermittedError
    nil
  end
end
