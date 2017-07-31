# frozen_string_literal: true

class OStatus::Activity::Post < OStatus::Activity::Creation
  def perform
    status, just_created = super

    if just_created
      status.mentions.includes(:account).each do |mention|
        mentioned_account = mention.account
        next unless mentioned_account.local?
        NotifyService.new.call(mentioned_account, mention)
      end
    end

    status
  end

  private

  def reblog
    nil
  end
end
