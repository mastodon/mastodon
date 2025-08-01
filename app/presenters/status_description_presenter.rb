# frozen_string_literal: true

class StatusDescriptionPresenter
  JOIN = ' · '

  attr_reader :status

  def initialize(status)
    @status = status
  end

  def description
    relevant_components
      .compact_blank
      .join("\n\n")
  end

  private

  def relevant_components
    [default_description].tap do |components|
      unless status.spoiler_text?
        components << status.text
        components << poll_summary
      end
    end
  end

  def default_description
    [media_summary, spoiler_warning]
      .compact_blank
      .join(JOIN)
  end

  def media_summary
    return if media_attachment_text.blank?

    I18n.t('statuses.attached.description', attached: media_attachment_text)
  end

  def media_attachment_text
    media_attachment_counts
      .reject { |_, value| value.zero? }
      .map { |key, value| I18n.t("statuses.attached.#{key}", count: value) }
      .join(JOIN)
  end

  def media_attachment_counts
    media_initial_counts.tap do |attachments|
      status.ordered_media_attachments.each do |media|
        attachments[media_type(media)] += 1
      end
    end
  end

  def media_initial_counts
    %i(image video audio).index_with(0)
  end

  def media_type(media)
    if media.video?
      :video
    elsif media.audio?
      :audio
    else
      :image
    end
  end

  def spoiler_warning
    return unless status.spoiler_text?

    I18n.t('statuses.content_warning', warning: status.spoiler_text)
  end

  def poll_summary
    return unless status.preloadable_poll

    status
      .preloadable_poll
      .options
      .map { |option| checkbox(option) }
      .join("\n")
  end

  def checkbox(option)
    ['[ ]', option].join(' ')
  end
end
