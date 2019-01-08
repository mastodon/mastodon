# frozen_string_literal: true

module StreamEntriesHelper
  EMBEDDED_CONTROLLER = 'statuses'
  EMBEDDED_ACTION = 'embed'

  def display_name(account, **options)
    if options[:custom_emojify]
      Formatter.instance.format_display_name(account, options)
    else
      account.display_name.presence || account.username
    end
  end

  def account_description(account)
    prepend_str = [
      [
        number_to_human(account.statuses_count, strip_insignificant_zeros: true),
        I18n.t('accounts.posts'),
      ].join(' '),

      [
        number_to_human(account.following_count, strip_insignificant_zeros: true),
        I18n.t('accounts.following'),
      ].join(' '),

      [
        number_to_human(account.followers_count, strip_insignificant_zeros: true),
        I18n.t('accounts.followers'),
      ].join(' '),
    ].join(', ')

    [prepend_str, account.note].join(' · ')
  end

  def media_summary(status)
    attachments = { image: 0, video: 0 }

    status.media_attachments.each do |media|
      if media.video?
        attachments[:video] += 1
      else
        attachments[:image] += 1
      end
    end

    text = attachments.to_a.reject { |_, value| value.zero? }.map { |key, value| I18n.t("statuses.attached.#{key}", count: value) }.join(' · ')

    return if text.blank?

    I18n.t('statuses.attached.description', attached: text)
  end

  def status_text_summary(status)
    return if status.spoiler_text.blank?
    I18n.t('statuses.content_warning', warning: status.spoiler_text)
  end

  def status_description(status)
    components = [[media_summary(status), status_text_summary(status)].reject(&:blank?).join(' · ')]
    components << status.text if status.spoiler_text.blank?
    components.reject(&:blank?).join("\n\n")
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
    rtl_words = text.scan(/[\p{Hebrew}\p{Arabic}\p{Syriac}\p{Thaana}\p{Nko}]+/m)

    if rtl_words.present?
      total_size = text.size.to_f
      rtl_size(rtl_words) / total_size > 0.3
    else
      false
    end
  end

  def fa_visibility_icon(status)
    case status.visibility
    when 'public'
      fa_icon 'globe fw'
    when 'unlisted'
      fa_icon 'unlock-alt fw'
    when 'private'
      fa_icon 'lock fw'
    when 'direct'
      fa_icon 'envelope fw'
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

  def rtl_size(words)
    words.reduce(0) { |acc, elem| acc + elem.size }.to_f
  end

  def embedded_view?
    params[:controller] == EMBEDDED_CONTROLLER && params[:action] == EMBEDDED_ACTION
  end
end
