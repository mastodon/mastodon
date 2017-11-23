# frozen_string_literal: true

class SuspendAccountService < BaseService
  def call(account, options = {})
    @account = account
    @options = options

    purge_user!
    purge_profile!
    purge_content!
  end

  private

  def purge_user!
    if @options[:remove_user]
      @account.user&.destroy
    else
      @account.user&.disable!
    end
  end

  def purge_content!
    @account.statuses.reorder(nil).find_in_batches do |statuses|
      BatchedRemoveStatusService.new.call(statuses)
    end
  end

  def purge_profile!
    @account.suspended    = true
    @account.display_name = ''
    @account.note         = ''
    @account.avatar.destroy
    @account.header.destroy
    @account.save!
  end
end
