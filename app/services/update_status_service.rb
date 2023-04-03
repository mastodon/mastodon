# frozen_string_literal: true

class UpdateStatusService < BaseService
  include Redisable
  include LanguagesHelper

  class NoChangesSubmittedError < StandardError; end

  # @param [Status] status
  # @param [Integer] account_id
  # @param [Hash] options
  # @option options [Array<Integer>] :media_ids
  # @option options [Array<Hash>] :media_attributes
  # @option options [Hash] :poll
  # @option options [String] :text
  # @option options [String] :spoiler_text
  # @option options [Boolean] :sensitive
  # @option options [String] :language
  # @option options [String] :content_type
  def call(status, account_id, options = {})
    @status                    = status
    @options                   = options
    @account_id                = account_id
    @media_attachments_changed = false
    @poll_changed              = false

    Status.transaction do
      create_previous_edit!
      update_media_attachments! if @options.key?(:media_ids)
      update_poll! if @options.key?(:poll)
      update_immediate_attributes!
      create_edit!
    end

    queue_poll_notifications!
    reset_preview_card!
    update_metadata!
    broadcast_updates!

    @status
  rescue NoChangesSubmittedError
    # For calls that result in no changes, swallow the error
    # but get back to the original state

    @status.reload
  end

  private

  def update_media_attachments!
    previous_media_attachments = @status.ordered_media_attachments.to_a
    next_media_attachments     = validate_media!
    added_media_attachments    = next_media_attachments - previous_media_attachments

    (@options[:media_attributes] || []).each do |attributes|
      media = next_media_attachments.find { |attachment| attachment.id == attributes[:id].to_i }
      next if media.nil?

      media.update!(attributes.slice(:thumbnail, :description, :focus))
      @media_attachments_changed ||= media.significantly_changed?
    end

    MediaAttachment.where(id: added_media_attachments.map(&:id)).update_all(status_id: @status.id)

    @status.ordered_media_attachment_ids = (@options[:media_ids] || []).map(&:to_i) & next_media_attachments.map(&:id)
    @media_attachments_changed ||= previous_media_attachments.map(&:id) != @status.ordered_media_attachment_ids
    @status.media_attachments.reload
  end

  def validate_media!
    return [] if @options[:media_ids].blank? || !@options[:media_ids].is_a?(Enumerable)

    raise Mastodon::ValidationError, I18n.t('media_attachments.validations.too_many') if @options[:media_ids].size > 4 || @options[:poll].present?

    media_attachments = @status.account.media_attachments.where(status_id: [nil, @status.id]).where(scheduled_status_id: nil).where(id: @options[:media_ids].take(4).map(&:to_i)).to_a

    raise Mastodon::ValidationError, I18n.t('media_attachments.validations.images_and_video') if media_attachments.size > 1 && media_attachments.find(&:audio_or_video?)
    raise Mastodon::ValidationError, I18n.t('media_attachments.validations.not_ready') if media_attachments.any?(&:not_processed?)

    media_attachments
  end

  def update_poll!
    previous_poll        = @status.preloadable_poll
    @previous_expires_at = previous_poll&.expires_at

    if @options[:poll].present?
      poll = previous_poll || @status.account.polls.new(status: @status, votes_count: 0)

      # If for some reasons the options were changed, it invalidates all previous
      # votes, so we need to remove them
      @poll_changed = true if @options[:poll][:options] != poll.options || ActiveModel::Type::Boolean.new.cast(@options[:poll][:multiple]) != poll.multiple

      poll.options     = @options[:poll][:options]
      poll.hide_totals = @options[:poll][:hide_totals] || false
      poll.multiple    = @options[:poll][:multiple] || false
      poll.expires_in  = @options[:poll][:expires_in]
      poll.reset_votes! if @poll_changed
      poll.save!

      @status.poll_id = poll.id
    elsif previous_poll.present?
      previous_poll.destroy
      @poll_changed = true
      @status.poll_id = nil
    end

    @poll_changed = true if @previous_expires_at != @status.preloadable_poll&.expires_at
  end

  def update_immediate_attributes!
    @status.text         = @options[:text].presence || @options.delete(:spoiler_text) || '' if @options.key?(:text)
    @status.spoiler_text = @options[:spoiler_text] || '' if @options.key?(:spoiler_text)
    @status.sensitive    = @options[:sensitive] || @options[:spoiler_text].present? if @options.key?(:sensitive) || @options.key?(:spoiler_text)
    @status.language     = valid_locale_cascade(@options[:language], @status.language, @status.account.user&.preferred_posting_language, I18n.default_locale)
    @status.content_type = @options[:content_type] || @status.content_type

    # We raise here to rollback the entire transaction
    raise NoChangesSubmittedError unless significant_changes?

    @status.edited_at = Time.now.utc
    @status.save!
  end

  def reset_preview_card!
    return unless @status.text_previously_changed?

    @status.preview_cards.clear
    LinkCrawlWorker.perform_async(@status.id)
  end

  def update_metadata!
    ProcessHashtagsService.new.call(@status)
    ProcessMentionsService.new.call(@status)
  end

  def broadcast_updates!
    DistributionWorker.perform_async(@status.id, { 'update' => true })
    ActivityPub::StatusUpdateDistributionWorker.perform_async(@status.id) unless @status.local_only?
  end

  def queue_poll_notifications!
    poll = @status.preloadable_poll

    # If the poll had no expiration date set but now has, or now has a sooner
    # expiration date, schedule a notification

    return unless poll.present? && poll.expires_at.present?

    PollExpirationNotifyWorker.remove_from_scheduled(poll.id) if @previous_expires_at.present? && @previous_expires_at > poll.expires_at
    PollExpirationNotifyWorker.perform_at(poll.expires_at + 5.minutes, poll.id)
  end

  def create_previous_edit!
    # We only need to create a previous edit when no previous edits exist, e.g.
    # when the status has never been edited. For other cases, we always create
    # an edit, so the step can be skipped

    return if @status.edits.any?

    @status.snapshot!(at_time: @status.created_at, rate_limit: false)
  end

  def create_edit!
    @status.snapshot!(account_id: @account_id)
  end

  def significant_changes?
    @status.changed? || @poll_changed || @media_attachments_changed
  end
end
