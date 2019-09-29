# frozen_string_literal: true

class NodeInfoSerializer < ActiveModel::Serializer
  include RoutingHelper

  attributes :version, :usage, :software, :services,
             :protocols, :metadata

  attribute :open_registrations, key: :openRegistrations

  def version
    '2.0'
  end

  def usage
    {
      users: {
        total: instance_presenter.user_count,
        activeHalfyear: instance_presenter.active_user_count_months(6),
        activeMonth: instance_presenter.active_user_count,
      },
      localPosts: instance_presenter.status_count,
    }
  end

  def software
    {
      version: Mastodon::Version.to_s,
      name: 'mastodon',
    }
  end

  def services
    {
      outbound: [],
      inbound: [],
    }
  end

  def protocols
    %w(activitypub)
  end

  def open_registrations
    Setting.registrations_mode == 'open'
  end

  def metadata
    return @_metadata if defined?(@_metadata)

    @_metadata = {
      nodeName: instance_presenter.site_title,
      nodeDescription: instance_presenter.site_description,
      nodeTerms: instance_presenter.site_terms,
      siteContactEmail: instance_presenter.site_contact_email,
      domain_count: instance_presenter.domain_count,
      features: features,
      invitesEnabled: Setting.min_invite_role != 'admin',
    }
    @_metadata[:federation] = federation if Setting.show_domain_blocks == 'all'
  end

  def features
    %w(mastodon_api mastodon_api_streaming)
  end

  def federation
    DomainBlock.with_user_facing_limitations.each_with_object(Hash.new { |h, k| h[k] = [] }) do |block, feds|
      feds[block.severity] << block.domain if %w(silence suspend).include?(block.severity)
      feds[:reject_media] << block.domain if block.reject_media
    end
  end

  private

  def instance_presenter
    @instance_presenter ||= InstancePresenter.new
  end
end
