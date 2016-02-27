module ProfileHelper
  def display_name(account)
    account.display_name.blank? ? account.username : account.display_name
  end

  def profile_url(account)
    account.local? ? super(name: account.username) : account.url
  end

  def status_url(status)
    status.local? ? super(name: status.account.username, id: status.stream_entry.id) : status.url
  end
end
