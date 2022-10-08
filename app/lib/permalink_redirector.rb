# frozen_string_literal: true

class PermalinkRedirector
  include RoutingHelper

  def initialize(path)
    @path = path
  end

  def redirect_path
    if path_segments[0].present? && path_segments[0].start_with?('@') && path_segments[1] =~ /\d/
      find_status_url_by_id(path_segments[1])
    elsif path_segments[0].present? && path_segments[0].start_with?('@')
      find_account_url_by_name(path_segments[0])
    elsif path_segments[0] == 'statuses' && path_segments[1] =~ /\d/
      find_status_url_by_id(path_segments[1])
    elsif path_segments[0] == 'accounts' && path_segments[1] =~ /\d/
      find_account_url_by_id(path_segments[1])
    end
  end

  private

  def path_segments
    @path_segments ||= @path.gsub(/\A\//, '').split('/')
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
