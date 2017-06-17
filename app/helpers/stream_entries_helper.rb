# frozen_string_literal: true

module StreamEntriesHelper
  EMBEDDED_CONTROLLER = 'stream_entries'
  EMBEDDED_ACTION = 'embed'

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

  def rtl_status?(status)
    status.local? ? rtl?(status.text) : rtl?(strip_tags(status.text))
  end

  def rtl?(text)
    text = simplified_text(text)
    rtl_characters = /[\p{Hebrew}|\p{Arabic}|\p{Syriac}|\p{Thaana}|\p{Nko}]+/m.match(text)

    if rtl_characters.present?
      total_size = text.size.to_f
      rtl_size(rtl_characters.to_a) / total_size > 0.3
    else
      false
    end
  end

  private

  def simplified_text(text)
    text.dup.tap do |new_text|
      URI.extract(new_text).each do |url|
        new_text.gsub!(url, '')
      end

      new_text.gsub!(Account::MENTION_RE, '')
      new_text.gsub!(Tag::HASHTAG_RE, '')
      new_text.gsub!(/\s+/, '')
    end
  end

  def rtl_size(characters)
    characters.reduce(0) { |acc, elem| acc + elem.size }.to_f
  end

  def embedded_view?
    params[:controller] == EMBEDDED_CONTROLLER && params[:action] == EMBEDDED_ACTION
  end
end
