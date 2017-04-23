# frozen_string_literal: true

module FlashesHelper
  def user_facing_flashes
    flash.to_hash.slice('alert', 'error', 'notice', 'success')
  end
end
