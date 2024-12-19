# frozen_string_literal: true

SimpleNavigation::Configuration.run do |navigation|
  self_destruct = SelfDestructHelper.self_destruct?

  navigation.items do |n|
    n.item :web, safe_join([material_symbol('chevron_left'), t('settings.back')]), root_path

    n.item :software_updates,
           safe_join([material_symbol('report'), t('admin.critical_update_pending')]),
           admin_software_updates_path,
           if: -> { Rails.configuration.x.mastodon.software_update_url.present? && current_user.can?(:view_devops) && SoftwareUpdate.urgent_pending? },
           html: { class: 'warning' }

    n.item :profile, safe_join([material_symbol('person'), t('settings.profile')]), settings_profile_path, if: -> { current_user.functional? && !self_destruct }, highlights_on: %r{/settings/profile|/settings/featured_tags|/settings/verification|/settings/privacy}

    n.item :preferences, safe_join([material_symbol('settings'), t('settings.preferences')]), settings_preferences_path, if: -> { current_user.functional? && !self_destruct } do |s|
      s.item :appearance, safe_join([material_symbol('computer'), t('settings.appearance')]), settings_preferences_appearance_path
      s.item :notifications, safe_join([material_symbol('mail'), t('settings.notifications')]), settings_preferences_notifications_path
      s.item :other, safe_join([material_symbol('tune'), t('preferences.other')]), settings_preferences_other_path
    end

    n.item :relationships, safe_join([material_symbol('groups'), t('settings.relationships')]), relationships_path, if: -> { current_user.functional? && !self_destruct } do |s|
      s.item :current, safe_join([material_symbol('groups'), t('settings.relationships')]), relationships_path
      s.item :severed_relationships, safe_join([material_symbol('link_off'), t('settings.severed_relationships')]), severed_relationships_path
    end

    n.item :filters, safe_join([material_symbol('filter_alt'), t('filters.index.title')]), filters_path, highlights_on: %r{/filters}, if: -> { current_user.functional? && !self_destruct }
    n.item :statuses_cleanup, safe_join([material_symbol('history'), t('settings.statuses_cleanup')]), statuses_cleanup_path, if: -> { current_user.functional_or_moved? && !self_destruct }

    n.item :security, safe_join([material_symbol('account_circle'), t('settings.account')]), edit_user_registration_path do |s|
      s.item :password, safe_join([material_symbol('lock'), t('settings.account_settings')]), edit_user_registration_path, highlights_on: %r{^/auth|/settings/delete|/settings/migration|/settings/aliases|/settings/login_activities|^/disputes}
      s.item :two_factor_authentication, safe_join([material_symbol('safety_check'), t('settings.two_factor_authentication')]), settings_two_factor_authentication_methods_path, highlights_on: %r{/settings/two_factor_authentication|/settings/otp_authentication|/settings/security_keys}
      s.item :authorized_apps, safe_join([material_symbol('list_alt'), t('settings.authorized_apps')]), oauth_authorized_applications_path, if: -> { !self_destruct }
    end

    n.item :data, safe_join([material_symbol('cloud_sync'), t('settings.import_and_export')]), settings_export_path do |s|
      s.item :import, safe_join([material_symbol('cloud_upload'), t('settings.import')]), settings_imports_path, highlights_on: %r{/settings/imports}, if: -> { current_user.functional? && !self_destruct }
      s.item :export, safe_join([material_symbol('cloud_download'), t('settings.export')]), settings_export_path
    end

    n.item :user_invites, safe_join([material_symbol('person_add'), t('invites.title')]), invites_path, if: -> { current_user.can?(:invite_users) && current_user.functional? && !self_destruct }
    n.item :development, safe_join([material_symbol('code'), t('settings.development')]), settings_applications_path, highlights_on: %r{/settings/applications}, if: -> { current_user.functional? && !self_destruct }

    n.item :trends, safe_join([material_symbol('trending_up'), t('admin.trends.title')]), admin_trends_statuses_path, if: -> { current_user.can?(:manage_taxonomies) && !self_destruct } do |s|
      s.item :statuses, safe_join([material_symbol('chat_bubble'), t('admin.trends.statuses.title')]), admin_trends_statuses_path, highlights_on: %r{/admin/trends/statuses}
      s.item :tags, safe_join([material_symbol('tag'), t('admin.trends.tags.title')]), admin_trends_tags_path, highlights_on: %r{/admin/trends/tags}
      s.item :links, safe_join([material_symbol('breaking_news'), t('admin.trends.links.title')]), admin_trends_links_path, highlights_on: %r{/admin/trends/links}
      s.item :follow_recommendations, safe_join([material_symbol('person_add'), t('admin.follow_recommendations.title')]), admin_follow_recommendations_path, highlights_on: %r{/admin/follow_recommendations}
    end

    n.item :moderation, safe_join([material_symbol('gavel'), t('moderation.title')]), nil, if: -> { current_user.can?(:manage_reports, :view_audit_log, :manage_users, :manage_invites, :manage_taxonomies, :manage_federation, :manage_blocks) && !self_destruct } do |s|
      s.item :reports, safe_join([material_symbol('flag'), t('admin.reports.title')]), admin_reports_path, highlights_on: %r{/admin/reports|admin/report_notes}, if: -> { current_user.can?(:manage_reports) }
      s.item :appeals, safe_join([material_symbol('feedback'), t('admin.disputes.appeals.title')]), admin_disputes_appeals_path, highlights_on: %r{/admin/disputes/appeals}, if: -> { current_user.can?(:manage_appeals) }
      s.item :accounts, safe_join([material_symbol('groups'), t('admin.accounts.title')]), admin_accounts_path(origin: 'local'), highlights_on: %r{/admin/accounts|admin/account_moderation_notes|/admin/pending_accounts|/admin/users}, if: -> { current_user.can?(:manage_users) }
      s.item :tags, safe_join([material_symbol('tag'), t('admin.tags.title')]), admin_tags_path, highlights_on: %r{/admin/tags}, if: -> { current_user.can?(:manage_taxonomies) }
      s.item :invites, safe_join([material_symbol('person_add'), t('admin.invites.title')]), admin_invites_path, if: -> { current_user.can?(:manage_invites) }
      s.item :instances, safe_join([material_symbol('cloud'), t('admin.instances.title')]), admin_instances_path(limited: limited_federation_mode? ? nil : '1'), highlights_on: %r{/admin/instances|/admin/domain_blocks|/admin/domain_allows|/admin/export_domain_blocks}, if: lambda {
        current_user.can?(:manage_federation)
      }
      s.item :email_domain_blocks, safe_join([material_symbol('mail'), t('admin.email_domain_blocks.title')]), admin_email_domain_blocks_path, highlights_on: %r{/admin/email_domain_blocks}, if: -> { current_user.can?(:manage_blocks) }
      s.item :ip_blocks, safe_join([material_symbol('hide_source'), t('admin.ip_blocks.title')]), admin_ip_blocks_path, highlights_on: %r{/admin/ip_blocks}, if: -> { current_user.can?(:manage_blocks) }
      s.item :action_logs, safe_join([material_symbol('list'), t('admin.action_logs.title')]), admin_action_logs_path, if: -> { current_user.can?(:view_audit_log) }
    end

    n.item :admin, safe_join([material_symbol('manufacturing'), t('admin.title')]), nil, if: -> { current_user.can?(:view_dashboard, :manage_settings, :manage_rules, :manage_announcements, :manage_custom_emojis, :manage_webhooks, :manage_federation) && !self_destruct } do |s|
      s.item :dashboard, safe_join([material_symbol('speed'), t('admin.dashboard.title')]), admin_dashboard_path, if: -> { current_user.can?(:view_dashboard) }
      s.item :settings, safe_join([material_symbol('tune'), t('admin.settings.title')]), admin_settings_path, if: -> { current_user.can?(:manage_settings) }, highlights_on: %r{/admin/settings}
      s.item :terms_of_service, safe_join([material_symbol('description'), t('admin.terms_of_service.title')]), admin_terms_of_service_index_path, highlights_on: %r{/admin/terms_of_service}, if: -> { current_user.can?(:manage_rules) }
      s.item :rules, safe_join([material_symbol('gavel'), t('admin.rules.title')]), admin_rules_path, highlights_on: %r{/admin/rules}, if: -> { current_user.can?(:manage_rules) }
      s.item :warning_presets, safe_join([material_symbol('warning'), t('admin.warning_presets.title')]), admin_warning_presets_path, highlights_on: %r{/admin/warning_presets}, if: -> { current_user.can?(:manage_settings) }
      s.item :roles, safe_join([material_symbol('contact_mail'), t('admin.roles.title')]), admin_roles_path, highlights_on: %r{/admin/roles}, if: -> { current_user.can?(:manage_roles) }
      s.item :announcements, safe_join([material_symbol('campaign'), t('admin.announcements.title')]), admin_announcements_path, highlights_on: %r{/admin/announcements}, if: -> { current_user.can?(:manage_announcements) }
      s.item :custom_emojis, safe_join([material_symbol('mood'), t('admin.custom_emojis.title')]), admin_custom_emojis_path, highlights_on: %r{/admin/custom_emojis}, if: -> { current_user.can?(:manage_custom_emojis) }
      s.item :webhooks, safe_join([material_symbol('inbox'), t('admin.webhooks.title')]), admin_webhooks_path, highlights_on: %r{/admin/webhooks}, if: -> { current_user.can?(:manage_webhooks) }
      s.item :fasp, safe_join([material_symbol('extension'), t('admin.fasp.title')]), admin_fasp_providers_path, highlights_on: %r{/admin/fasp}, if: -> { current_user.can?(:manage_federation) }
      s.item :relays, safe_join([material_symbol('captive_portal'), t('admin.relays.title')]), admin_relays_path, highlights_on: %r{/admin/relays}, if: -> { !limited_federation_mode? && current_user.can?(:manage_federation) }
    end

    n.item :sidekiq, safe_join([material_symbol('diamond'), 'Sidekiq']), sidekiq_path, link_html: { target: 'sidekiq' }, if: -> { current_user.can?(:view_devops) }
    n.item :pghero, safe_join([material_symbol('database'), 'PgHero']), pghero_path, link_html: { target: 'pghero' }, if: -> { current_user.can?(:view_devops) }
    n.item :logout, safe_join([material_symbol('logout'), t('auth.logout')]), destroy_user_session_path, link_html: { 'data-method' => 'delete' }
  end
end
