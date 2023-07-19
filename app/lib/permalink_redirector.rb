# frozen_string_literal: true

class PermalinkRedirector
  include RoutingHelper

  def initialize(path)
    @path = path
  end

  def redirect_path
    if at_username_status_request? || statuses_status_request?
      find_status_url_by_id(second_segment)
    elsif at_username_request?
      find_account_url_by_name(first_segment)
    elsif accounts_request? && record_integer_id_request?
      find_account_url_by_id(second_segment)
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
    @path_segments ||= @path.delete_prefix('/').split('/')
  end

  def find_status_url_by_id(id)
    status = Status.find_by(id: id)
    ActivityPub::TagManager.instance.url_for(status) if status&.distributable? && !status.account.local?
  end

  def find_account_url_by_id(id)
    account = Account.find_by(id: id)
    ActivityPub::TagManager.instance.url_for(account) if account.present? && !account.local?
  end

  def find_account_url_by_name(name)
    username, domain = name.gsub(/\A@/, '').split('@')
    domain           = nil if TagManager.instance.local_domain?(domain)
    account          = Account.find_remote(username, domain)

    ActivityPub::TagManager.instance.url_for(account) if account.present? && !account.local?
  end
end
