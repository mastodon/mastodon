# frozen_string_literal: true

class PostStatusService < BaseService
  include Redisable
  include LanguagesHelper

  MIN_SCHEDULE_OFFSET = 5.minutes.freeze

  # Post a text status update, fetch and notify remote users mentioned
  # @param [Account] account Account from which to post
  # @param [Hash] options
  # @option [String] :text Message
  # @option [Status] :thread Optional status to reply to
  # @option [Boolean] :sensitive
  # @option [String] :visibility
  # @option [String] :spoiler_text
  # @option [String] :language
  # @option [String] :scheduled_at
  # @option [Hash] :poll Optional poll to attach
  # @option [Enumerable] :media_ids Optional array of media IDs to attach
  # @option [Doorkeeper::Application] :application
  # @option [String] :idempotency Optional idempotency key
  # @option [Boolean] :with_rate_limit
  # @return [Status]
  def call(account, options = {})
    @account     = account
    @options     = options
    @text        = @options[:text] || ''
    @in_reply_to = @options[:thread]
    @quote_id    = @options[:quote_id]
    # @remote_media= []

    return idempotency_duplicate if idempotency_given? && idempotency_duplicate?

    validate_media!
    preprocess_attributes!
    preprocess_quote!

    if scheduled?
      schedule_status!
    else
      process_status!
      postprocess_status!
      bump_potential_friendship!
    end

    redis.setex(idempotency_key, 3_600, @status.id) if idempotency_given?

    @status
  end

  private

  def status_from_uri(uri)
    ActivityPub::TagManager.instance.uri_to_resource(uri, Status)
  end

  def quote_from_url(url)
    return nil if url.nil?

    quote = ResolveURLService.new.call(url)
    status_from_uri(quote.uri) if quote
  rescue
    nil
  end

  def preprocess_attributes!
    @sensitive    = (@options[:sensitive].nil? ? @account.user&.setting_default_sensitive : @options[:sensitive]) || @options[:spoiler_text].present?
    @text         = @options.delete(:spoiler_text) if @text.blank? && @options[:spoiler_text].present?
    @visibility   = @options[:visibility] || @account.user&.setting_default_privacy
    @visibility   = :unlisted if @visibility&.to_sym == :public && @account.silenced?
    @scheduled_at = @options[:scheduled_at]&.to_datetime
    @scheduled_at = nil if scheduled_in_the_past?
    if @quote_id.nil? && md = @text.match(/QT:\s*\[\s*(https:\/\/.+?)\s*\]/)
      @quote_id = quote_from_url(md[1])&.id
      @text.sub!(/QT:\s*\[.*?\]/, '')
    end
  rescue ArgumentError
    raise ActiveRecord::RecordInvalid
  end

  def preprocess_quote!
    if @quote_id.present?
      quote = Status.find(@quote_id)
      @quote_id = quote.reblog_of_id.to_s if quote.reblog?
    end
  end

  def process_status!
    # The following transaction block is needed to wrap the UPDATEs to
    # the media attachments when the status is created

    ApplicationRecord.transaction do
      @status = @account.statuses.create!(status_attributes)
    end

    process_hashtags_service.call(@status)
    process_mentions_service.call(@status)
  end

  def schedule_status!
    status_for_validation = @account.statuses.build(status_attributes)

    if status_for_validation.valid?
      # Marking the status as destroyed is necessary to prevent the status from being
      # persisted when the associated media attachments get updated when creating the
      # scheduled status.
      status_for_validation.destroy

      # The following transaction block is needed to wrap the UPDATEs to
      # the media attachments when the scheduled status is created

      ApplicationRecord.transaction do
        @status = @account.scheduled_statuses.create!(scheduled_status_attributes)
      end
    else
      raise ActiveRecord::RecordInvalid
    end
  end

  def local_only_option(local_only, in_reply_to, federation_setting)
    return in_reply_to&.local_only? if local_only.nil? # XXX temporary, just until clients implement to avoid leaking local_only posts
    return federation_setting if local_only.nil?
    local_only
  end

  def content_type_option(content_type, content_type_setting)
    return content_type_setting if content_type.nil?
    content_type
  end

  def postprocess_status!
    Trends.tags.register(@status)
    LinkCrawlWorker.perform_async(@status.id)
    DistributionWorker.perform_async(@status.id)
    unless @status.local_only?
      ActivityPub::DistributionWorker.perform_async(@status.id)
      PollExpirationNotifyWorker.perform_at(@status.poll.expires_at, @status.poll.id) if @status.poll
    end
  end

  def validate_media!
    if @options[:media_ids].blank? || !@options[:media_ids].is_a?(Enumerable)
      @media = []
      return
    end

    raise Mastodon::ValidationError, I18n.t('media_attachments.validations.too_many') if @options[:media_ids].size > 9 || @options[:poll].present?

    @media = @account.media_attachments.where(status_id: nil).where(id: @options[:media_ids].take(9).map(&:to_i))

    raise Mastodon::ValidationError, I18n.t('media_attachments.validations.images_and_video') if @media.size > 1 && @media.find(&:audio_or_video?)
    raise Mastodon::ValidationError, I18n.t('media_attachments.validations.not_ready') if @media.any?(&:not_processed?)
  end

  def process_remote_attachments
    # IMAGE: [https://s3.mashiro.top/view/2022/02/24/6f3f209aa55e3083f0659ecb62448fc0.jpg]
    image_array = @text.scan(/IMAGE:\s*\[\s*((?:https|http):\/\/.+?)\s*\](?:\s*\{\s*((?:https|http):\/\/.+?)\s*\})*/)
    video_array = @text.scan(/VIDEO:\s*\[\s*((?:https|http):\/\/.+?)\s*\](?:\s*\{\s*((?:https|http):\/\/.+?)\s*\})*/)

    @text       = @text.gsub(/(?:IMAGE|VIDEO):\s*\[\s*((?:https|http):\/\/.+?)\s*\](?:\s*\{\s*((?:https|http):\/\/.+?)\s*\})*/, '')

    return [] if image_array.blank? && video_array.blank?

    # raise Mastodon::ValidationError, I18n.t('media_attachments.validations.too_many_nine') if @media.to_a.size + image_array.size > 9 || @options[:poll].present?

    media_attachments = []
    media_array = if !video_array.empty?
                    [video_array.first]
                  else
                    image_array
                  end

    media_array.each do |media|
      next if media_attachments.size >= 9

      original  = Addressable::URI.parse(media[0]).normalize.to_s
      thumbnail = thumbnail_remote_url(media[1])
      media_attachment = MediaAttachment.create(
        account: @account,
        remote_url: original,
        thumbnail_remote_url: thumbnail,
        description: "Media source: #{original}",
        focus: nil,
        blurhash: nil
      )
      media_attachments << media_attachment

      media_attachment.download_file!
      media_attachment.download_thumbnail!
      media_attachment.save!

    rescue Mastodon::UnexpectedResponseError, HTTP::TimeoutError, HTTP::ConnectionError, OpenSSL::SSL::SSLError
      RedownloadMediaWorker.perform_in(rand(30..600).seconds, media_attachment.id)
    rescue Seahorse::Client::NetworkingError
      nil
    end

    media_attachments
  rescue Addressable::URI::InvalidURIError => e
    Rails.logger.debug "Invalid URL in attachment: #{e}"
    media_attachments
  end

  def thumbnail_remote_url(url)
    return nil if url == nil
    Addressable::URI.parse(url).normalize.to_s
  rescue Addressable::URI::InvalidURIError
    nil
  end

  def process_mentions_service
    ProcessMentionsService.new
  end

  def process_hashtags_service
    ProcessHashtagsService.new
  end

  def scheduled?
    @scheduled_at.present?
  end

  def idempotency_key
    "idempotency:status:#{@account.id}:#{@options[:idempotency]}"
  end

  def idempotency_given?
    @options[:idempotency].present?
  end

  def idempotency_duplicate
    if scheduled?
      @account.schedule_statuses.find(@idempotency_duplicate)
    else
      @account.statuses.find(@idempotency_duplicate)
    end
  end

  def idempotency_duplicate?
    @idempotency_duplicate = redis.get(idempotency_key)
  end

  def scheduled_in_the_past?
    @scheduled_at.present? && @scheduled_at <= Time.now.utc + MIN_SCHEDULE_OFFSET
  end

  def bump_potential_friendship!
    return if !@status.reply? || @account.id == @status.in_reply_to_account_id
    ActivityTracker.increment('activity:interactions')
    return if @account.following?(@status.in_reply_to_account_id)
    PotentialFriendshipTracker.record(@account.id, @status.in_reply_to_account_id, :reply)
  end

  def status_attributes
    remote_media_attachment = process_remote_attachments.take(9)

    if !remote_media_attachment.blank?
      @media = @media.to_a.concat(remote_media_attachment)
      remote_media_attachment_ids = remote_media_attachment.map(&:id)
      @options[:media_ids] = @options[:media_ids] || []
      @options[:media_ids].concat(remote_media_attachment_ids)
    end

    {
      text: @text,
      media_attachments: @media || [],
      ordered_media_attachment_ids: (@options[:media_ids] || []).map(&:to_i) & @media.map(&:id),
      thread: @in_reply_to,
      poll_attributes: poll_attributes,
      sensitive: @sensitive,
      spoiler_text: @options[:spoiler_text] || '',
      visibility: @visibility,
      language: valid_locale_cascade(@options[:language], @account.user&.preferred_posting_language, I18n.default_locale),
      application: @options[:application],
      rate_limit: @options[:with_rate_limit],
      local_only: local_only_option(@options[:local_only], @in_reply_to, @account.user&.setting_default_federation),
      content_type: content_type_option(@options[:content_type], @account.user&.setting_default_content_type),
      quote_id: @quote_id,
    }.compact
  end

  def scheduled_status_attributes
    {
      scheduled_at: @scheduled_at,
      media_attachments: @media || [],
      params: scheduled_options,
    }
  end

  def poll_attributes
    return if @options[:poll].blank?

    @options[:poll].merge(account: @account, voters_count: 0)
  end

  def scheduled_options
    @options.tap do |options_hash|
      options_hash[:in_reply_to_id]  = options_hash.delete(:thread)&.id
      options_hash[:application_id]  = options_hash.delete(:application)&.id
      options_hash[:scheduled_at]    = nil
      options_hash[:idempotency]     = nil
      options_hash[:with_rate_limit] = false
    end
  end
end
