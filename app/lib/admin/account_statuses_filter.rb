# frozen_string_literal: true

class Admin::AccountStatusesFilter < AccountStatusesFilter
  private

  def blocked?
    false
  end
end
