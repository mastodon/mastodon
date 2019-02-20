# frozen_string_literal: true

class NodeInfoSerializer
  include RoutingHelper

  def node_info
    {
      version: version,
      usage: usage,
      software: software,
      services: services,
      protocols: protocols,
      openRegistrations: open_registrations,
      metaData: meta_data,
    }
  end

  def version
    '2.1'
  end

  def usage
    {
      users: {
        total: instance_presenter.user_count,
        activeHalfyear: instance_presenter.active_count(timespan: Time.zone.now - 6.months..Time.zone.now),
        activeMonth: instance_presenter.active_count,
      },
      localPosts: instance_presenter.status_count,
    }
  end

  def software
    {
      version: Mastodon::Version.to_s,
      name: 'mastodon',
      repository: Mastodon::Version.source_base_url,
    }
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

  def open_registrations
    Setting.open_registrations
  end

  def meta_data
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
