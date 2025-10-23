# frozen_string_literal: true

class Api::V1::Timelines::TopicController < Api::V1::Timelines::BaseController
  before_action :require_user!, if: :require_auth?

  private

  def require_auth?
    if truthy_param?(:local)
      Setting.local_topic_feed_access != 'all'
    elsif truthy_param?(:remote)
      Setting.remote_topic_feed_access != 'all'
    else
      Setting.local_topic_feed_access != 'all' || Setting.remote_topic_feed_access != 'all'
    end
  end
end
