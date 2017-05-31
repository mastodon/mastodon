# frozen_string_literal: true

class SuspendAccountService < BaseService
  def call(account)
    @account = account

    purge_content
    purge_profile
    unsubscribe_push_subscribers
  end

  private

  def purge_content
    @account.statuses.reorder(nil).find_each do |status|
      # This federates out deletes to previous followers
      RemoveStatusService.new.call(status)
    end

    [
      @account.media_attachments,
      @account.stream_entries,
      @account.notifications,
      @account.favourites,
      @account.active_relationships,
      @account.passive_relationships
    ].each do |association|
      destroy_all(association)
    end
  end

  def purge_profile
    @account.suspended    = true
    @account.display_name = ''
    @account.note         = ''
    @account.avatar.destroy
    @account.header.destroy
    @account.save!
  end

  def unsubscribe_push_subscribers
    destroy_all(@account.subscriptions)
  end

  def destroy_all(association)
    association.in_batches.destroy_all
  end
end
