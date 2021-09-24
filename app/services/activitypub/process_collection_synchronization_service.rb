# frozen_string_literal: true

class ActivityPub::ProcessCollectionSynchronizationService < BaseService
  include JsonLdHelper

  def call(account, value)
    return unless collection_synchronization_enabled?

    @account = account
    @params  = parse_value(value)

    return if unknown_collection? || collection_up_to_date?

    ActivityPub::FollowersSynchronizationWorker.perform_async(@account.id, @params['url'])
  rescue Parslet::ParseFailed
    Rails.logger.warn 'Error parsing Collection-Synchronization header'
  end

  private

  def parse_value(value)
    SignatureVerification::SignatureParamsTransformer.new.apply(SignatureVerification::SignatureParamsParser.new.parse(value))
  end

  def unknown_collection?
    @params['collectionId'] != @account.followers_url || invalid_origin?(@params['url'])
  end

  def collection_up_to_date?
    @account.local_followers_hash == @params['digest']
  end

  def collection_synchronization_enabled?
    ENV['DISABLE_FOLLOWERS_SYNCHRONIZATION'] != 'true'
  end
end
