# frozen_string_literal: true

class NodeInfoSerializer < ActiveModel::Serializer
  include RoutingHelper

  attributes :version, :usage, :software, :services,
             :protocols, :openRegistrations, :metadata

  def version
    object.adapter.serializer.instance_options[:version]
  end

  def usage
    {
      users: {
        total: instance_presenter.user_count,
        activeHalfyear: instance_presenter.active_user_count_month,
        activeMonth: instance_presenter.active_user_count,
      },
      localPosts: instance_presenter.status_count,
    }
  end

  def software
    sw = {
      version: Mastodon::Version.to_s,
      name: 'mastodon'
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
    %w(ostatus activitypub)
  end

  def openRegistrations
    Setting.open_registrations
  end

  def metadata
    {
      nodeName: instance_presenter.site_title,
      nodeDescription: instance_presenter.site_description,
      nodeTerms: instance_presenter.site_terms,
      siteContactEmail: instance_presenter.site_contact_email,
      domain_count: instance_presenter.domain_count,
      features: features,
      invitesEnabled: Setting.min_invite_role != 'admin',
      federation: federation,
    }
  end

  def features
    %w(mastodon_api mastodon_api_streaming)
  end

  def federation
    domains = DomainBlock.all
    feds = {
      reject_media: [],
      reject_reports: [],
    }
    domains.each do |domain|
      feds[domain.severity] = [] unless feds.keys.include?(domain.severity)
      feds[domain.severity] << domain.domain
      feds[:reject_media] << domain.domain if domain.reject_media
      feds[:reject_reports] << domain.domain if domain.reject_reports
    end
    feds
  end

  private

  def instance_presenter
    @instance_presenter ||= InstancePresenter.new
  end
end
