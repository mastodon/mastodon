# frozen_string_literal: true

class DeleteMuteWorker
  include Sidekiq::Worker

  def perform(mute_id)
    mute = Mute.find_by(id: mute_id)
    UnmuteService.new.call(mute.account, mute.target_account) if mute&.expired?
  end
end
