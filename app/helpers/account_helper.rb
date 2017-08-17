# frozen_string_literal: true

module AccountHelper
  def protocol_for_display(protocol)
    case protocol
    when 'activitypub'
      'ActivityPub'
    when 'ostatus'
      'OStatus'
    else
      protocol
    end
  end
end
