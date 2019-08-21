# frozen_string_literal: true

class NodeInfoSerializer < ActiveModel::Serializer
  include RoutingHelper

  attributes :version, :usage, :software, :services,
             :protocols, :metadata

  attribute :open_registrations, key: :openRegistrations

  def version
    object.adapter.serializer.instance_options[:version]
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
    sw = {
      version: Mastodon::Version.to_s,
      name: 'mastodon',
    }
    sw[:repository] = Mastodon::Version.source_base_url if version == '2.1'
    sw
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
    blocks = DomainBlock.with_user_facing_limitations
    feds = {
      reject_media: [],
    }
    blocks.each do |block|
      feds[block.severity] = [] if %w(silence suspend).include?(block.severity) && !feds.keys.include?(block.severity)
      feds[block.severity] << block.domain
      feds[:reject_media] << block.domain if block.reject_media
    end
    feds
  end

  private

  def instance_presenter
    @instance_presenter ||= InstancePresenter.new
  end
end
