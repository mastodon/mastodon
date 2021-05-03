# frozen_string_literal: true

class ActivityPub::ProcessCollectionService < BaseService
  include JsonLdHelper

  def call(body, account, **options)
    @account = account
    @json    = Oj.load(body, mode: :strict)
    @options = options

    return if !supported_context? || (different_actor? && verify_account!.nil?) || suspended_actor? || @account.local?

    case @json['type']
    when 'Collection', 'CollectionPage'
      process_items @json['items']
    when 'OrderedCollection', 'OrderedCollectionPage'
      process_items @json['orderedItems']
    else
      process_items [@json]
    end
  rescue Oj::ParseError
    nil
  end

  private

  def different_actor?
    @json['actor'].present? && value_or_id(@json['actor']) != @account.uri
  end

  def suspended_actor?
    @account.suspended? && !activity_allowed_while_suspended?
  end

  def activity_allowed_while_suspended?
    %w(Delete Reject Undo Update).include?(@json['type'])
  end

  def process_items(items)
    items.reverse_each.map { |item| process_item(item) }.compact
  end

  def supported_context?
    super(@json)
  end

  def process_item(item)
    activity = ActivityPub::Activity.factory(item, @account, **@options)
    activity&.perform
  end

  def verify_account!
    @options[:relayed_through_account] = @account
    @account = ActivityPub::LinkedDataSignature.new(@json).verify_account!
  rescue JSON::LD::JsonLdError => e
    Rails.logger.debug "Could not verify LD-Signature for #{value_or_id(@json['actor'])}: #{e.message}"
    nil
  end
end
