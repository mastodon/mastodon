# frozen_string_literal: true

class StatusFinder
  attr_reader :url

  def initialize(url)
    @url = url
  end

  def status
    verify_action!

    raise ActiveRecord::RecordNotFound unless TagManager.instance.local_url?(url)

    case recognized_params[:controller]
    when 'statuses'
      Status.find(recognized_params[:id])
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  private

  def recognized_params
    Rails.application.routes.recognize_path(url)
  end

  def verify_action!
    raise ActiveRecord::RecordNotFound unless recognized_params[:action] == 'show'
  end
end
