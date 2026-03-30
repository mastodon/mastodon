# frozen_string_literal: true

class Api::V1::Timelines::TopicController < Api::V1::Timelines::BaseController
  before_action :require_user!, if: :require_auth?

  private

  def require_auth?
    if truthy_param?(:local)
      Setting.local_topic_feed_access != 'public'
    elsif truthy_param?(:remote)
      Setting.remote_topic_feed_access != 'public'
    else
      Setting.local_topic_feed_access != 'public' || Setting.remote_topic_feed_access != 'public'
    end
  end
end
