class RemoveStatusService < BaseService
  def call(status)
    status.destroy!

    # TODO
    # Remove from timelines of self, followers, and mentioned accounts
    # For remote mentioned accounts, send delete Salmon
    # Push delete event through ActionCable
  end
end
