# frozen_string_literal: true

class PermalinkRedirector
  include RoutingHelper

  def initialize(path)
    @path = path
    @object = nil
  end

  def object
    @object ||= begin
      if at_username_status_request? || statuses_status_request?
        status = Status.find_by(id: second_segment)
        status if status&.distributable? && !status&.local?
      elsif at_username_request?
        username, domain = first_segment.delete_prefix('@').split('@')
        domain = nil if TagManager.instance.local_domain?(domain)
        account = Account.find_remote(username, domain)
        account unless account&.local?
      elsif accounts_request? && record_integer_id_request?
        account = Account.find_by(id: second_segment)
        account unless account&.local?
      end
    end
  end

  def redirect_path
    return ActivityPub::TagManager.instance.url_for(object) if object.present?

    @path.delete_prefix('/deck') if @path.start_with?('/deck')
  end

  def redirect_uri
    return ActivityPub::TagManager.instance.uri_for(object) if object.present?

    @path.delete_prefix('/deck') if @path.start_with?('/deck')
  end

  def redirect_confirmation_path
    case object.class.name
    when 'Account'
      redirect_account_path(object.id)
    when 'Status'
      redirect_status_path(object.id)
    else
      @path.delete_prefix('/deck') if @path.start_with?('/deck')
    end
  end

  private

  def at_username_status_request?
    at_username_request? && record_integer_id_request?
  end

  def statuses_status_request?
    statuses_request? && record_integer_id_request?
  end

  def at_username_request?
    first_segment.present? && first_segment.start_with?('@')
  end

  def statuses_request?
    first_segment == 'statuses'
  end

  def accounts_request?
    first_segment == 'accounts'
  end

  def record_integer_id_request?
    second_segment =~ /\d/
  end

  def first_segment
    path_segments.first
  end

  def second_segment
    path_segments.second
  end

  def path_segments
    @path_segments ||= @path.delete_prefix('/deck').delete_prefix('/').split('/')
  end
end
