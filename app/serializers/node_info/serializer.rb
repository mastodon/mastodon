# frozen_string_literal: true

class NodeInfo::Serializer < ActiveModel::Serializer
  include RoutingHelper

  attributes :version, :software, :protocols, :services, :usage, :open_registrations, :metadata

  def version
    '2.0'
  end

  def software
    { name: 'mastodon', version: Mastodon::Version.to_s }
  end

  def services
    { outbound: [], inbound: [] }
  end

  def protocols
    %w(activitypub)
  end

  def usage
    {
      users: {
        total: instance_presenter.user_count,
        active_month: instance_presenter.active_user_count(4),
        active_halfyear: instance_presenter.active_user_count(24),
      },

      local_posts: instance_presenter.status_count,
    }
  end

  def open_registrations
    Setting.registrations_mode != 'none' && !Rails.configuration.x.single_user_mode
  end

  def metadata
    {}
  end

  private

  def instance_presenter
    @instance_presenter ||= InstancePresenter.new
  end
end
