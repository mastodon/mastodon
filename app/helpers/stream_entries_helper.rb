# frozen_string_literal: true

module StreamEntriesHelper
  def display_name(account)
    account.display_name.blank? ? account.username : account.display_name
  end

  def acct(account)
    "@#{account.acct}#{@external_links && account.local? ? "@#{Rails.configuration.x.local_domain}" : ''}"
  end

  def avatar_for_status_url(status)
    status.reblog? ? status.reblog.account.avatar.url(:original) : status.account.avatar.url(:original)
  end

  def style_classes(status, is_predecessor, is_successor, include_threads)
    classes = ['entry']
    classes << 'entry-predecessor' if is_predecessor
    classes << 'entry-reblog' if status.reblog?
    classes << 'entry-successor' if is_successor
    classes << 'entry-center' if include_threads
    classes.join(' ')
  end

  def microformats_classes(status, is_direct_parent, is_direct_child)
    classes = []
    classes << 'p-in-reply-to' if is_direct_parent
    classes << 'p-repost-of' if status.reblog? && is_direct_parent
    classes << 'p-comment' if is_direct_child
    classes.join(' ')
  end

  def microformats_h_class(status, is_predecessor, is_successor, include_threads)
    return 'h-cite' if is_predecessor || status.reblog || is_successor
    return 'h-entry' if !include_threads
    return ''
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

  def rtl?(text)
    return false if text.empty?

    matches = /[\p{Hebrew}|\p{Arabic}|\p{Syriac}|\p{Thaana}|\p{Nko}]+/m.match(text)

    return false unless matches

    rtl_size = matches.to_a.reduce(0) { |acc, elem| acc + elem.size }.to_f
    ltr_size = text.strip.size.to_f

    rtl_size / ltr_size > 0.3
  end
end
