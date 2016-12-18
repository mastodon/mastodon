# frozen_string_literal: true

module StreamEntriesHelper
  def display_name(account)
    account.display_name.blank? ? account.username : account.display_name
  end

  def acct(account)
    "@#{account.acct}#{@external_links && account.local? ? "@#{Rails.configuration.x.local_domain}" : ''}"
  end

  def avatar_for_status_url(status)
    status.reblog? ? status.reblog.account.avatar.url( :original) : status.account.avatar.url( :original)
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
    date < 5.days.ago ? date.strftime('%d.%m.%Y') : "#{time_ago_in_words(date)} ago"
  end

  def reblogged_by_me_class(status)
    user_signed_in? && @reblogged.key?(status.id) ? 'reblogged' : ''
  end

  def favourited_by_me_class(status)
    user_signed_in? && @favourited.key?(status.id) ? 'favourited' : ''
  end

  def proper_status(status)
    status.reblog? ? status.reblog : status
  end
end
