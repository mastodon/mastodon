# frozen_string_literal: true

class StreamEntryFinder
  attr_reader :url

  def initialize(url)
    @url = url
  end

  def stream_entry
    verify_action!

    case recognized_params[:controller]
    when 'stream_entries'
      StreamEntry.find(recognized_params[:id])
    when 'statuses'
      Status.find(recognized_params[:id]).stream_entry
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  private

  def recognized_params
    Rails.application.routes.recognize_path(url)
  end

  def verify_action!
    unless recognized_params[:action] == 'show'
      raise ActiveRecord::RecordNotFound
    end
  end
end
