# frozen_string_literal: true

class AppealService < BaseService
  def call(strike, text)
    @strike = strike
    @text   = text

    create_appeal!
    notify_staff!

    @appeal
  end

  private

  def create_appeal!
    @appeal = Appeal.create!(
      strike: @strike,
      text: @text,
      account: @strike.target_account
    )
  end

  def notify_staff!
    User.those_who_can(:manage_appeals).includes(:account).find_each do |u|
      AdminMailer.with(recipient: u.account).new_appeal(@appeal).deliver_later if u.allows_appeal_emails?
    end
  end
end
