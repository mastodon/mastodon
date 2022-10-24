# frozen_string_literal: true

class ApproveGroupStatusService < BaseService
  include Redisable

  def call(status)
    return unless status.local? && status.group.present?

    @status = status
    @status.approval_status = :approved
    @status.save

    distribute_to_group!
  end

  private

  def distribute_to_group!
    redis.publish("timeline:group:#{@status.group_id}", anonymous_payload)
  end

  def anonymous_payload
    @anonymous_payload ||= Oj.dump(
      event: :update,
      payload: InlineRenderer.render(@status, nil, :status)
    )
  end
end
