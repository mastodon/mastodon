# frozen_string_literal: true

module StreamEntriesHelper
  EMBEDDED_CONTROLLER = 'stream_entries'.freeze
  EMBEDDED_ACTION = 'embed'.freeze

  def display_name(account)
    account.display_name.presence || account.username
  end

  def stream_link_target
    embedded_view? ? '_blank' : nil
  end

  def acct(account)
    if embedded_view? && account.local?
      "@#{account.acct}@#{Rails.configuration.x.local_domain}"
    else
      "@#{account.acct}"
    end
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
    if is_predecessor || status.reblog? || is_successor
      'h-cite'
    elsif include_threads
      ''
    else
      'h-entry'
    end
  end

  def rtl?(text)
    rtl_charcount = text.gsub(/[^\p{Hebrew}|\p{Arabic}|\p{Syriac}|\p{Thaana}|\p{Nko}]/m, '').strip.size.to_f

    if rtl_charcount.positive?
      # Remove mentions before counting characters to decide RTL ratio
      justtext = text.gsub(Account::MENTION_RE, '')
      # Remove Email addresses
      # justtext = justtext.gsub(/^([a-z0-9_\.-]+)@([\da-z\.-]+)\.([a-z\.]{2,6})$/, '')
      # Naiive catcher for URLs
      justtext = justtext.gsub(/[-A-Za-z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b([-A-Za-z0-9@:%_\+.~#?&\/=]*)/, '')

      total_size = justtext.strip.size.to_f
      rtl_charcount / total_size > 0.3
    else
      false
    end
  end

  private

  def embedded_view?
    params[:controller] == EMBEDDED_CONTROLLER && params[:action] == EMBEDDED_ACTION
  end
end
