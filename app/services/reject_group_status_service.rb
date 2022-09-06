# frozen_string_literal: true

class RejectGroupStatusService < BaseService
  include Redisable

  def call(status)
    return unless status.local? && status.group.present?

    @status = status

    if @status.approved?
      @status.approval_status = :revoked
      @status.save
      remove_from_group!
    else
      @status.approval_status = :rejected
      @status.save
      # TODO: send info to author somehow
    end
  end

  private

  def remove_from_group!
    payload = Oj.dump(event: :delete, payload: @status.id.to_s)
    redis.publish("timeline:group:#{@status.group_id}", payload)
  end
end
