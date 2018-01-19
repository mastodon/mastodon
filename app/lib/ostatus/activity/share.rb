# frozen_string_literal: true

class OStatus::Activity::Share < OStatus::Activity::Creation
  def perform
    reblog.nil? ? nil : super
  end

  def object
    @xml.at_xpath('.//activity:object', activity: OStatus::TagManager::AS_XMLNS)
  end

  private

  def reblog
    return @reblog if defined? @reblog

    original_status = OStatus::Activity::Remote.new(object).perform
    return if original_status.nil?

    @reblog = original_status.reblog? ? original_status.reblog : original_status
  end
end
