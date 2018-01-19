# frozen_string_literal: true

class OStatus::Activity::Post < OStatus::Activity::Creation
  private

  def reblog
    nil
  end
end
