# frozen_string_literal: true

class ResolveURLService < BaseService
  include JsonLdHelper
  include Authorization

  attr_reader :url

  def call(url, on_behalf_of: nil)
    @url = url
    @on_behalf_of = on_behalf_of

    return process_local_url if local_url?

    process_url unless fetched_atom_feed.nil?
  end

  private

  def process_url
    if equals_or_includes_any?(type, %w(Application Group Organization Person Service))
      FetchRemoteAccountService.new.call(atom_url, body, protocol)
    elsif equals_or_includes_any?(type, %w(Note Article Image Video))
      FetchRemoteStatusService.new.call(atom_url, body, protocol)
    end
  end

  def fetched_atom_feed
    @_fetched_atom_feed ||= FetchAtomService.new.call(url)
  end

  def atom_url
    fetched_atom_feed.first
  end

  def body
    fetched_atom_feed.second[:prefetched_body]
  end

  def protocol
    fetched_atom_feed.third
  end

  def type
    return json_data['type'] if protocol == :activitypub

    case xml_root
    when 'feed'
      'Person'
    when 'entry'
      'Note'
    end
  end

  def json_data
    @_json_data ||= body_to_json(body)
  end

  def xml_root
    xml_data.root.name
  end

  def xml_data
    @_xml_data ||= Nokogiri::XML(body, nil, 'utf-8')
  end

  def local_url?
    TagManager.instance.local_url?(@url)
  end

  def process_local_url
    recognized_params = Rails.application.routes.recognize_path(@url)

    return unless recognized_params[:action] == 'show'

    if recognized_params[:controller] == 'stream_entries'
      status = StreamEntry.find_by(id: recognized_params[:id])&.status
      check_local_status(status)
    elsif recognized_params[:controller] == 'statuses'
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
    # Do not disclose the existence of status the user is not authorized to see
    nil
  end
end
