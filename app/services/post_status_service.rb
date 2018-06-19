# frozen_string_literal: true

class PostStatusService < BaseService
  # Post a text status update, fetch and notify remote users mentioned
  # @param [Account] account Account from which to post
  # @param [String] text Message
  # @param [Status] in_reply_to Optional status to reply to
  # @param [Hash] options
  # @option [Boolean] :sensitive
  # @option [String] :visibility
  # @option [String] :spoiler_text
  # @option [Enumerable] :media_ids Optional array of media IDs to attach
  # @option [Doorkeeper::Application] :application
  # @option [String] :idempotency Optional idempotency key
  # @return [Status]
  def call(account, text, in_reply_to = nil, **options)
    if options[:idempotency].present?
      existing_id = redis.get("idempotency:status:#{account.id}:#{options[:idempotency]}")
      return Status.find(existing_id) if existing_id
    end

    media  = validate_media!(options[:media_ids])
    status = nil
    text   = options.delete(:spoiler_text) if text.blank? && options[:spoiler_text].present?
    text   = '.' if text.blank? && media.present?

    ApplicationRecord.transaction do
      status = account.statuses.create!(text: text,
                                        media_attachments: media || [],
                                        thread: in_reply_to,
                                        sensitive: (options[:sensitive].nil? ? account.user&.setting_default_sensitive : options[:sensitive]) || options[:spoiler_text].present?,
                                        spoiler_text: options[:spoiler_text] || '',
                                        visibility: options[:visibility] || account.user&.setting_default_privacy,
                                        language: language_from_option(options[:language]) || LanguageDetector.instance.detect(text, account),
                                        application: options[:application])
    end

    process_hashtags_service.call(status)
    process_mentions_service.call(status)

    LinkCrawlWorker.perform_async(status.id) unless status.spoiler_text?
    DistributionWorker.perform_async(status.id)
    Pubsubhubbub::DistributionWorker.perform_async(status.stream_entry.id)
    ActivityPub::DistributionWorker.perform_async(status.id)
    ActivityPub::ReplyDistributionWorker.perform_async(status.id) if status.reply? && status.thread.account.local?

    if options[:idempotency].present?
      redis.setex("idempotency:status:#{account.id}:#{options[:idempotency]}", 3_600, status.id)
    end

    status
  end

  private

  def validate_media!(media_ids)
    return if media_ids.blank? || !media_ids.is_a?(Enumerable)

    raise Mastodon::ValidationError, I18n.t('media_attachments.validations.too_many') if media_ids.size > 4

    media = MediaAttachment.where(status_id: nil).where(id: media_ids.take(4).map(&:to_i))

    raise Mastodon::ValidationError, I18n.t('media_attachments.validations.images_and_video') if media.size > 1 && media.find(&:video?)

    media
  end

  def language_from_option(str)
    ISO_639.find(str)&.alpha2
  end

  def process_mentions_service
    ProcessMentionsService.new
  end

  def process_hashtags_service
    ProcessHashtagsService.new
  end

  def redis
    Redis.current
  end
end
