# frozen_string_literal: true

class UnreadNotificationsPresenter < ActiveModelSerializers::Model
  attr_reader :count

  def initialize(user)
    @count = user.account
                 .notifications
                 .where('id > ?', user.last_read_notification_id)
                 .limit(limit)
                 .count

    @count = Float::INFINITY if @count >= limit
  end

  def limit
    40
  end
end
