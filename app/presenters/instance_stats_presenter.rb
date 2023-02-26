# frozen_string_literal: true

class InstanceStatsPresenter < ActiveModelSerializers::Model
  attributes :delivery_stats

  def initialize(domain)
    @domain = domain
  end

  def delivery_histories
    @history ||= DeliveryStatsTracker.new(@domain).hourly_delivery_histories(3.days.ago)
  end
end
