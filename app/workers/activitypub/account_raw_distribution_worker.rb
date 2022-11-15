# frozen_string_literal: true

class ActivityPub::AccountRawDistributionWorker < ActivityPub::RawDistributionWorker
  protected

  def inboxes
    @inboxes ||= AccountReachFinder.new(@account).inboxes
  end
end
