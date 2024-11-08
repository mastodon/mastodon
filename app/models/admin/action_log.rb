# frozen_string_literal: true

class Admin::ActionLog < ApplicationRecord
  self.ignored_columns += %w(
    recorded_changes
  )

  belongs_to :account
  belongs_to :target, polymorphic: true, optional: true

  before_validation :set_human_identifier
  before_validation :set_route_param
  before_validation :set_permalink

  scope :latest, -> { order(id: :desc) }

  def action
    super.to_sym
  end

  private

  def set_human_identifier
    self.human_identifier = target.to_log_human_identifier if target.respond_to?(:to_log_human_identifier)
  end

  def set_route_param
    self.route_param = target.to_log_route_param if target.respond_to?(:to_log_route_param)
  end

  def set_permalink
    self.permalink = target.to_log_permalink if target.respond_to?(:to_log_permalink)
  end
end
