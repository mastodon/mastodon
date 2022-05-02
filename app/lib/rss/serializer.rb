# frozen_string_literal: true

class RSS::Serializer
  include FormattingHelper

  private

  def render_statuses(builder, statuses)
    statuses.each do |status|
      builder.item do |item|
        item.title(status_title(status))
            .link(ActivityPub::TagManager.instance.url_for(status))
            .pub_date(status.created_at)
            .description(status_description(status))

        status.ordered_media_attachments.each do |media|
          item.enclosure(full_asset_url(media.file.url(:original, false)), media.file.content_type, media.file.size)
        end
      end
    end
  end

  def status_title(status)
    preview = status.proper.spoiler_text.presence || PlainTextFormatter.new(status.text, status.local?).to_s

    if preview.length > 128 || preview[0, 128].include?("\n")
      preview = preview[0, 128]
      preview = preview[0, preview.index("\n").presence || 128] + '…'
    end

    preview = "#{status.proper.spoiler_text.present? ? 'CW ' : ''}“#{preview}”#{status.proper.sensitive? ? ' (sensitive)' : ''}"

    if status.reblog?
      "#{status.account.acct} boosted #{status.reblog.account.acct}: #{preview}"
    else
      "#{status.account.acct}: #{preview}"
    end
  end

  def status_description(status)
    if status.proper.spoiler_text?
      status.proper.spoiler_text
    else
      html = status_content_format(status.proper).to_str
      after_html = ''

      if status.proper.preloadable_poll
        poll_options_html = status.proper.preloadable_poll.options.map { |o| "[ ] #{o}" }.join('<br />')
        after_html = "<p>#{poll_options_html}</p>"
      end

      "#{html}#{after_html}"
    end
  end
end
