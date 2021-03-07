# frozen_string_literal: true

class ActivityPub::Activity::Announce < ActivityPub::Activity
  def perform
    return reject_payload! if delete_arrived_first?(@json['id']) || !related_to_local_activity?

    lock_or_fail("announce:#{@object['id']}") do
      dereference_object!
      @original_status = status_from_object

      return reject_payload! if @original_status.nil? || !announceable?(@original_status)

      @status = Status.find_by(account: @account, reblog: @original_status)

      if @status.nil?
        process_status
      elsif @options[:delivered_to_account_id].present?
        postprocess_audience_and_deliver
      end
    else
      raise Mastodon::RaceConditionError
    end

    @status
  end

  private

  def process_status
    @mentions = []
    @params   = {}

    process_status_params
    process_audience

    ApplicationRecord.transaction do
      @status = Status.create!(@params)
      attach_mentions(@status)
    end

    distribute(@status)
  end

  def process_status_params
    @params = begin
      {
        account: @account,
        reblog: @original_status,
        uri: @json['id'],
        created_at: @json['published'],
        override_timestamps: @options[:override_timestamps],
        visibility: visibility_from_audience
      }
    end
  end

  def process_audience
    conversation_uri = value_or_id(@object['context'])

    (audience_to + audience_cc).uniq.each do |audience|
      next if audience == ActivityPub::TagManager::COLLECTIONS[:public] || audience == conversation_uri

      # Unlike with tags, there is no point in resolving accounts we don't already
      # know here, because silent mentions would only be used for local access
      # control anyway
      account = account_from_uri(audience)

      next if account.nil? || @mentions.any? { |mention| mention.account_id == account.id }

      @mentions << Mention.new(account: account, silent: true)

      # If there is at least one silent mention, then the status can be considered
      # as a limited-audience status, and not strictly a direct message, but only
      # if we considered a direct message in the first place
      @params[:visibility] = :limited if @params[:visibility] == :direct
    end

    # If the payload was delivered to a specific inbox, the inbox owner must have
    # access to it, unless they already have access to it anyway
    return if @options[:delivered_to_account_id].nil? || @mentions.any? { |mention| mention.account_id == @options[:delivered_to_account_id] }

    @mentions << Mention.new(account_id: @options[:delivered_to_account_id], silent: true)

    @params[:visibility] = :limited if @params[:visibility] == :direct
  end

  def postprocess_audience_and_deliver
    return if @status.mentions.find_by(account_id: @options[:delivered_to_account_id])

    delivered_to_account = Account.find(@options[:delivered_to_account_id])

    @status.mentions.create(account: delivered_to_account, silent: true)
    @status.update(visibility: :limited) if @status.direct_visibility?

    return unless delivered_to_account.following?(@account)

    FeedInsertWorker.perform_async(@status.id, delivered_to_account.id, :home)
  end

  def attach_mentions(status)
    @mentions.each do |mention|
      mention.status = status
      mention.save
    end
  end

  def audience_to
    as_array(@json['to']).map { |x| value_or_id(x) }
  end

  def audience_cc
    as_array(@json['cc']).map { |x| value_or_id(x) }
  end

  def visibility_from_audience
    if audience_to.any? { |to| ActivityPub::TagManager.instance.public_collection?(to) }
      :public
    elsif audience_cc.any? { |cc| ActivityPub::TagManager.instance.public_collection?(cc) }
      :unlisted
    elsif audience_to.include?(@account.followers_url)
      :private
    else
      :direct
    end
  end

  def announceable?(status)
    status.account_id == @account.id || status.distributable?
  end

  def related_to_local_activity?
    followed_by_local_accounts? || requested_through_relay? || reblog_of_local_status?
  end

  def requested_through_relay?
    super || Relay.find_by(inbox_url: @account.inbox_url)&.enabled?
  end

  def reblog_of_local_status?
    ActivityPub::TagManager.instance.local_uri?(object_uri) && status_from_uri(object_uri)&.account&.local?
  end
end
