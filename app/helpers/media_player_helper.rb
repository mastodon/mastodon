# frozen_string_literal: true

module MediaPlayerHelper
  PLAYER_HEIGHT = 380
  PLAYER_WIDTH = 670

  def media_player_card_type(status)
    status.ordered_media_attachments.any?(&:larger_media_format?) ? 'player' : 'summary_large_image'
  end
end
