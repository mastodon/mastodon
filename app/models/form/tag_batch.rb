# frozen_string_literal: true

class Form::TagBatch
  include ActiveModel::Model
  include Authorization

  attr_accessor :tag_ids, :action, :current_account

  def save
    case action
    when 'approve'
      approve!
    when 'reject'
      reject!
    end
  end

  private

  def tags
    Tag.where(id: tag_ids)
  end

  def approve!
    tags.each { |tag| authorize(tag, :update?) }
    tags.update_all(trendable: true, reviewed_at: action_time)
  end

  def reject!
    tags.each { |tag| authorize(tag, :update?) }
    tags.update_all(trendable: false, reviewed_at: action_time)
  end

  def action_time
    @action_time ||= Time.now.utc
  end
end
