# frozen_string_literal: true

module StreamEntriesHelper
  def display_name(account)
    account.display_name.presence || account.username
  end

  def stream_link_target
    embedded_view? ? '_blank' : nil
  end

  def acct(account)
    "@#{account.acct}#{embedded_view? && account.local? ? "@#{Rails.configuration.x.local_domain}" : ''}"
  end

  def entry_classes(status, is_predecessor, is_successor, include_threads)
    classes = ['entry']
    classes << 'entry-reblog u-repost-of h-cite' if status.reblog?
    classes << 'entry-predecessor u-in-reply-to h-cite' if is_predecessor
    classes << 'entry-successor u-comment h-cite' if is_successor
    classes << 'entry-center h-entry' if include_threads
    classes.join(' ')
  end

  def rtl?(text)
    return false if text.empty?

    matches = /[\p{Hebrew}|\p{Arabic}|\p{Syriac}|\p{Thaana}|\p{Nko}]+/m.match(text)

    return false unless matches

    rtl_size = matches.to_a.reduce(0) { |acc, elem| acc + elem.size }.to_f
    ltr_size = text.strip.size.to_f

    rtl_size / ltr_size > 0.3
  end

  private

  def embedded_view?
    params[:controller] == 'stream_entries' && params[:action] == 'embed'
  end
end
