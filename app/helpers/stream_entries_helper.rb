module StreamEntriesHelper
  def display_name(account)
    account.display_name.blank? ? account.username : account.display_name
  end

  def avatar_for_status_url(status)
    status.reblog? ? status.reblog.account.avatar.url(:small) : status.account.avatar.url(:small)
  end

  def entry_classes(status, is_predecessor, is_successor, include_threads)
    classes = ['entry']
    classes << 'entry-reblog' if status.reblog?
    classes << 'entry-predecessor' if is_predecessor
    classes << 'entry-successor' if is_successor
    classes << 'entry-center' if include_threads
    classes.join(' ')
  end

  def relative_time(date)
    date < 5.days.ago ? date.strftime("%d.%m.%Y") : "#{time_ago_in_words(date)} ago"
  end
end
