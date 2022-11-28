# frozen_string_literal: true

class ActivityPub::ProcessStatusUpdateService < BaseService
  include JsonLdHelper
  include Redisable
  include Lockable

  def call(status, json, request_id: nil)
    raise ArgumentError, 'Status has unsaved changes' if status.changed?

    @json                      = json
    @status_parser             = ActivityPub::Parser::StatusParser.new(@json)
    @uri                       = @status_parser.uri
    @status                    = status
    @account                   = status.account
    @media_attachments_changed = false
    @poll_changed              = false
    @request_id                = request_id

    # Only native types can be updated at the moment
    return @status if !expected_type? || already_updated_more_recently?

    if @status_parser.edited_at.present? && (@status.edited_at.nil? || @status_parser.edited_at > @status.edited_at)
      handle_explicit_update!
    else
      handle_implicit_update!
    end

    @status
  end

  private

  def handle_explicit_update!
    last_edit_date = @status.edited_at.presence || @status.created_at

    # Only allow processing one create/update per status at a time
    with_lock("create:#{@uri}") do
      Status.transaction do
        record_previous_edit!
        update_media_attachments!
        update_poll!
        update_immediate_attributes!
        update_metadata!
        create_edits!
      end

      download_media_files!
      queue_poll_notifications!

      next unless significant_changes?

      reset_preview_card!
      broadcast_updates!
    end

    # TODO: can be removed when https://github.com/mastodon/mastodon/pull/24046 is fixed
    StatusesIndex.import! @status if Chewy.enabled?

    forward_activity! if significant_changes? && @status_parser.edited_at > last_edit_date
  end

  def handle_implicit_update!
    with_lock("create:#{@uri}") do
      update_poll!(allow_significant_changes: false)
      queue_poll_notifications!
    end
  end

  def update_media_attachments!
    previous_media_attachments     = @status.media_attachments.to_a
    previous_media_attachments_ids = @status.ordered_media_attachment_ids || previous_media_attachments.map(&:id)
    @next_media_attachments        = []

    as_array(@json['attachment']).each do |attachment|
      media_attachment_parser = ActivityPub::Parser::MediaAttachmentParser.new(attachment)

      next if media_attachment_parser.remote_url.blank? || @next_media_attachments.size > 4

      begin
        media_attachment   = previous_media_attachments.find { |previous_media_attachment| previous_media_attachment.remote_url == media_attachment_parser.remote_url }
        media_attachment ||= MediaAttachment.new(account: @account, remote_url: media_attachment_parser.remote_url)

        # If a previously existing media attachment was significantly updated, mark
        # media attachments as changed even if none were added or removed
        @media_attachments_changed = true if media_attachment_parser.significantly_changes?(media_attachment)

        media_attachment.description          = media_attachment_parser.description
        media_attachment.focus                = media_attachment_parser.focus
        media_attachment.thumbnail_remote_url = media_attachment_parser.thumbnail_remote_url
        media_attachment.blurhash             = media_attachment_parser.blurhash
        media_attachment.status_id            = @status.id
        media_attachment.skip_download        = unsupported_media_type?(media_attachment_parser.file_content_type) || skip_download?
        media_attachment.save!

        @next_media_attachments << media_attachment
      rescue Addressable::URI::InvalidURIError => e
        Rails.logger.debug { "Invalid URL in attachment: #{e}" }
      end
    end

    added_media_attachments = @next_media_attachments - previous_media_attachments

    @status.ordered_media_attachment_ids = @next_media_attachments.map(&:id)

    @media_attachments_changed = true if @status.ordered_media_attachment_ids != previous_media_attachments_ids
  end

  def download_media_files!
    @next_media_attachments.each do |media_attachment|
      next if media_attachment.skip_download

      media_attachment.download_file! if media_attachment.remote_url_previously_changed?
      media_attachment.download_thumbnail! if media_attachment.thumbnail_remote_url_previously_changed?
      media_attachment.save
    rescue Mastodon::UnexpectedResponseError, HTTP::TimeoutError, HTTP::ConnectionError, OpenSSL::SSL::SSLError
      RedownloadMediaWorker.perform_in(rand(30..600).seconds, media_attachment.id)
    rescue Seahorse::Client::NetworkingError => e
      Rails.logger.warn "Error storing media attachment: #{e}"
    end

    @status.media_attachments.reload
  end

  def update_poll!(allow_significant_changes: true)
    previous_poll        = @status.preloadable_poll
    @previous_expires_at = previous_poll&.expires_at
    poll_parser          = ActivityPub::Parser::PollParser.new(@json)

    if poll_parser.valid?
      poll = previous_poll || @account.polls.new(status: @status)

      # If for some reasons the options were changed, it invalidates all previous
      # votes, so we need to remove them
      @poll_changed = true if poll_parser.significantly_changes?(poll)
      return if @poll_changed && !allow_significant_changes

      poll.last_fetched_at = Time.now.utc
      poll.options         = poll_parser.options
      poll.multiple        = poll_parser.multiple
      poll.expires_at      = poll_parser.expires_at
      poll.voters_count    = poll_parser.voters_count
      poll.cached_tallies  = poll_parser.cached_tallies
      poll.reset_votes! if @poll_changed
      poll.save!

      @status.poll_id = poll.id
    elsif previous_poll.present?
      return unless allow_significant_changes

      previous_poll.destroy!
      @poll_changed = true
      @status.poll_id = nil
    end
  end

  def update_immediate_attributes!
    @status.text         = @status_parser.text || ''
    @status.spoiler_text = @status_parser.spoiler_text || ''
    @status.sensitive    = @account.sensitized? || @status_parser.sensitive || false
    @status.language     = @status_parser.language

    @significant_changes = text_significantly_changed? || @status.spoiler_text_changed? || @media_attachments_changed || @poll_changed

    @status.edited_at = @status_parser.edited_at if significant_changes?

    @status.save!
  end

  def update_metadata!
    @raw_tags     = []
    @raw_mentions = []
    @raw_emojis   = []

    as_array(@json['tag']).each do |tag|
      if equals_or_includes?(tag['type'], 'Hashtag')
        @raw_tags << tag['name']
      elsif equals_or_includes?(tag['type'], 'Mention')
        @raw_mentions << tag['href']
      elsif equals_or_includes?(tag['type'], 'Emoji')
        @raw_emojis << tag
      end
    end

    update_tags!
    update_mentions!
    update_emojis!
  end

  def update_tags!
    @status.tags = Tag.find_or_create_by_names(@raw_tags)
  end

  def update_mentions!
    previous_mentions = @status.active_mentions.includes(:account).to_a
    current_mentions  = []

    @raw_mentions.each do |href|
      next if href.blank?

      account   = ActivityPub::TagManager.instance.uri_to_resource(href, Account)
      account ||= ActivityPub::FetchRemoteAccountService.new.call(href, request_id: @request_id)

      next if account.nil?

      mention   = previous_mentions.find { |x| x.account_id == account.id }
      mention ||= account.mentions.new(status: @status)

      current_mentions << mention
    end

    current_mentions.each do |mention|
      mention.save if mention.new_record?
    end

    # If previous mentions are no longer contained in the text, convert them
    # to silent mentions, since withdrawing access from someone who already
    # received a notification might be more confusing
    removed_mentions = previous_mentions - current_mentions

    Mention.where(id: removed_mentions.map(&:id)).update_all(silent: true) unless removed_mentions.empty?
  end

  def update_emojis!
    return if skip_download?

    @raw_emojis.each do |raw_emoji|
      custom_emoji_parser = ActivityPub::Parser::CustomEmojiParser.new(raw_emoji)

      next if custom_emoji_parser.shortcode.blank? || custom_emoji_parser.image_remote_url.blank?

      emoji = CustomEmoji.find_by(shortcode: custom_emoji_parser.shortcode, domain: @account.domain)

      next unless emoji.nil? || custom_emoji_parser.image_remote_url != emoji.image_remote_url || (custom_emoji_parser.updated_at && custom_emoji_parser.updated_at >= emoji.updated_at)

      begin
        emoji ||= CustomEmoji.new(domain: @account.domain, shortcode: custom_emoji_parser.shortcode, uri: custom_emoji_parser.uri)
        emoji.image_remote_url = custom_emoji_parser.image_remote_url
        emoji.save
      rescue Seahorse::Client::NetworkingError => e
        Rails.logger.warn "Error storing emoji: #{e}"
      end
    end
  end

  def expected_type?
    equals_or_includes_any?(@json['type'], %w(Note Question))
  end

  def record_previous_edit!
    @previous_edit = @status.build_snapshot(at_time: @status.created_at, rate_limit: false) if @status.edits.empty?
  end

  def create_edits!
    return unless significant_changes?

    @previous_edit&.save!
    @status.snapshot!(account_id: @account.id, rate_limit: false)
  end

  def skip_download?
    return @skip_download if defined?(@skip_download)

    @skip_download ||= DomainBlock.reject_media?(@account.domain)
  end

  def unsupported_media_type?(mime_type)
    mime_type.present? && !MediaAttachment.supported_mime_types.include?(mime_type)
  end

  def significant_changes?
    @significant_changes
  end

  def text_significantly_changed?
    return false unless @status.text_changed?

    old, new = @status.text_change
    HtmlAwareFormatter.new(old, false).to_s != HtmlAwareFormatter.new(new, false).to_s
  end

  def already_updated_more_recently?
    @status.edited_at.present? && @status_parser.edited_at.present? && @status.edited_at > @status_parser.edited_at
  end

  def reset_preview_card!
    @status.preview_cards.clear
    LinkCrawlWorker.perform_in(rand(1..59).seconds, @status.id)
  end

  def broadcast_updates!
    ::DistributionWorker.perform_async(@status.id, { 'update' => true })
  end

  def queue_poll_notifications!
    poll = @status.preloadable_poll

    # If the poll had no expiration date set but now has, or now has a sooner
    # expiration date, and people have voted, schedule a notification

    return unless poll.present? && poll.expires_at.present? && poll.votes.exists?

    PollExpirationNotifyWorker.remove_from_scheduled(poll.id) if @previous_expires_at.present? && @previous_expires_at > poll.expires_at
    PollExpirationNotifyWorker.perform_at(poll.expires_at + 5.minutes, poll.id)
  end

  def forward_activity!
    forwarder.forward! if forwarder.forwardable?
  end

  def forwarder
    @forwarder ||= ActivityPub::Forwarder.new(@account, @json, @status)
  end
end
