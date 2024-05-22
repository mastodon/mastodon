# frozen_string_literal: true

SimpleNavigation::Configuration.run do |navigation|
  self_destruct = SelfDestructHelper.self_destruct?

  navigation.items do |n|
    n.item :web, safe_join([fa_icon('chevron-left fw'), t('settings.back')]), root_path

    n.item :software_updates, safe_join([fa_icon('exclamation-circle fw'), t('admin.critical_update_pending')]), admin_software_updates_path, if: -> { ENV['UPDATE_CHECK_URL'] != '' && current_user.can?(:view_devops) && SoftwareUpdate.urgent_pending? }, html: { class: 'warning' }

    n.item :profile, safe_join([fa_icon('user fw'), t('settings.profile')]), settings_profile_path, if: -> { current_user.functional? && !self_destruct }, highlights_on: %r{/settings/profile|/settings/featured_tags|/settings/verification|/settings/privacy}

    n.item :preferences, safe_join([fa_icon('cog fw'), t('settings.preferences')]), settings_preferences_path, if: -> { current_user.functional? && !self_destruct } do |s|
      s.item :appearance, safe_join([fa_icon('desktop fw'), t('settings.appearance')]), settings_preferences_appearance_path
      s.item :notifications, safe_join([fa_icon('envelope fw'), t('settings.notifications')]), settings_preferences_notifications_path
      s.item :other, safe_join([fa_icon('cog fw'), t('preferences.other')]), settings_preferences_other_path
    end

    n.item :flavours, safe_join([fa_icon('paint-brush fw'), t('settings.flavours')]), settings_flavours_path do |flavours|
      Themes.instance.flavours.each do |flavour|
        flavours.item flavour.to_sym, safe_join([fa_icon('star fw'), t("flavours.#{flavour}.name", default: flavour)]), settings_flavour_path(flavour)
      end
    end

    n.item :relationships, safe_join([fa_icon('users fw'), t('settings.relationships')]), relationships_path, if: -> { current_user.functional? && !self_destruct } do |s|
      s.item :current, safe_join([fa_icon('users fw'), t('settings.relationships')]), relationships_path
      s.item :severed_relationships, safe_join([fa_icon('unlink fw'), t('settings.severed_relationships')]), severed_relationships_path
    end

    n.item :filters, safe_join([fa_icon('filter fw'), t('filters.index.title')]), filters_path, highlights_on: %r{/filters}, if: -> { current_user.functional? && !self_destruct }
    n.item :statuses_cleanup, safe_join([fa_icon('history fw'), t('settings.statuses_cleanup')]), statuses_cleanup_path, if: -> { current_user.functional_or_moved? && !self_destruct }

    n.item :security, safe_join([fa_icon('lock fw'), t('settings.account')]), edit_user_registration_path do |s|
      s.item :password, safe_join([fa_icon('lock fw'), t('settings.account_settings')]), edit_user_registration_path, highlights_on: %r{/auth/edit|/settings/delete|/settings/migration|/settings/aliases|/settings/login_activities|^/disputes}
      s.item :two_factor_authentication, safe_join([fa_icon('mobile fw'), t('settings.two_factor_authentication')]), settings_two_factor_authentication_methods_path, highlights_on: %r{/settings/two_factor_authentication|/settings/otp_authentication|/settings/security_keys}
      s.item :authorized_apps, safe_join([fa_icon('list fw'), t('settings.authorized_apps')]), oauth_authorized_applications_path, if: -> { !self_destruct }
    end

    n.item :data, safe_join([fa_icon('cloud-download fw'), t('settings.import_and_export')]), settings_export_path do |s|
      s.item :import, safe_join([fa_icon('cloud-upload fw'), t('settings.import')]), settings_imports_path, if: -> { current_user.functional? && !self_destruct }
      s.item :export, safe_join([fa_icon('cloud-download fw'), t('settings.export')]), settings_export_path
    end

    n.item :invites, safe_join([fa_icon('user-plus fw'), t('invites.title')]), invites_path, if: -> { current_user.can?(:invite_users) && current_user.functional? && !self_destruct }
    n.item :development, safe_join([fa_icon('code fw'), t('settings.development')]), settings_applications_path, highlights_on: %r{/settings/applications}, if: -> { current_user.functional? && !self_destruct }

    n.item :trends, safe_join([fa_icon('fire fw'), t('admin.trends.title')]), admin_trends_statuses_path, if: -> { current_user.can?(:manage_taxonomies) && !self_destruct } do |s|
      s.item :statuses, safe_join([fa_icon('comments-o fw'), t('admin.trends.statuses.title')]), admin_trends_statuses_path, highlights_on: %r{/admin/trends/statuses}
      s.item :tags, safe_join([fa_icon('hashtag fw'), t('admin.trends.tags.title')]), admin_trends_tags_path, highlights_on: %r{/admin/tags|/admin/trends/tags}
      s.item :links, safe_join([fa_icon('newspaper-o fw'), t('admin.trends.links.title')]), admin_trends_links_path, highlights_on: %r{/admin/trends/links}
    end

    n.item :moderation, safe_join([fa_icon('gavel fw'), t('moderation.title')]), nil, if: -> { current_user.can?(:manage_reports, :view_audit_log, :manage_users, :manage_invites, :manage_taxonomies, :manage_federation, :manage_blocks) && !self_destruct } do |s|
      s.item :reports, safe_join([fa_icon('flag fw'), t('admin.reports.title')]), admin_reports_path, highlights_on: %r{/admin/reports|admin/report_notes}, if: -> { current_user.can?(:manage_reports) }
      s.item :accounts, safe_join([fa_icon('users fw'), t('admin.accounts.title')]), admin_accounts_path(origin: 'local'), highlights_on: %r{/admin/accounts|admin/account_moderation_notes|/admin/pending_accounts|/admin/disputes|/admin/users}, if: -> { current_user.can?(:manage_users) }
      s.item :invites, safe_join([fa_icon('user-plus fw'), t('admin.invites.title')]), admin_invites_path, if: -> { current_user.can?(:manage_invites) }
      s.item :follow_recommendations, safe_join([fa_icon('user-plus fw'), t('admin.follow_recommendations.title')]), admin_follow_recommendations_path, highlights_on: %r{/admin/follow_recommendations}, if: -> { current_user.can?(:manage_taxonomies) }
      s.item :instances, safe_join([fa_icon('cloud fw'), t('admin.instances.title')]), admin_instances_path(limited: limited_federation_mode? ? nil : '1'), highlights_on: %r{/admin/instances|/admin/domain_blocks|/admin/domain_allows}, if: -> { current_user.can?(:manage_federation) }
      s.item :email_domain_blocks, safe_join([fa_icon('envelope fw'), t('admin.email_domain_blocks.title')]), admin_email_domain_blocks_path, highlights_on: %r{/admin/email_domain_blocks}, if: -> { current_user.can?(:manage_blocks) }
      s.item :ip_blocks, safe_join([fa_icon('ban fw'), t('admin.ip_blocks.title')]), admin_ip_blocks_path, highlights_on: %r{/admin/ip_blocks}, if: -> { current_user.can?(:manage_blocks) }
      s.item :action_logs, safe_join([fa_icon('bars fw'), t('admin.action_logs.title')]), admin_action_logs_path, if: -> { current_user.can?(:view_audit_log) }
    end

    n.item :admin, safe_join([fa_icon('cogs fw'), t('admin.title')]), nil, if: -> { current_user.can?(:view_dashboard, :manage_settings, :manage_rules, :manage_announcements, :manage_custom_emojis, :manage_webhooks, :manage_federation) && !self_destruct } do |s|
      s.item :dashboard, safe_join([fa_icon('tachometer fw'), t('admin.dashboard.title')]), admin_dashboard_path, if: -> { current_user.can?(:view_dashboard) }
      s.item :settings, safe_join([fa_icon('cogs fw'), t('admin.settings.title')]), admin_settings_path, if: -> { current_user.can?(:manage_settings) }, highlights_on: %r{/admin/settings}
      s.item :rules, safe_join([fa_icon('gavel fw'), t('admin.rules.title')]), admin_rules_path, highlights_on: %r{/admin/rules}, if: -> { current_user.can?(:manage_rules) }
      s.item :warning_presets, safe_join([fa_icon('warning fw'), t('admin.warning_presets.title')]), admin_warning_presets_path, highlights_on: %r{/admin/warning_presets}, if: -> { current_user.can?(:manage_settings) }
      s.item :roles, safe_join([fa_icon('vcard fw'), t('admin.roles.title')]), admin_roles_path, highlights_on: %r{/admin/roles}, if: -> { current_user.can?(:manage_roles) }
      s.item :announcements, safe_join([fa_icon('bullhorn fw'), t('admin.announcements.title')]), admin_announcements_path, highlights_on: %r{/admin/announcements}, if: -> { current_user.can?(:manage_announcements) }
      s.item :custom_emojis, safe_join([fa_icon('smile-o fw'), t('admin.custom_emojis.title')]), admin_custom_emojis_path, highlights_on: %r{/admin/custom_emojis}, if: -> { current_user.can?(:manage_custom_emojis) }
      s.item :webhooks, safe_join([fa_icon('inbox fw'), t('admin.webhooks.title')]), admin_webhooks_path, highlights_on: %r{/admin/webhooks}, if: -> { current_user.can?(:manage_webhooks) }
      s.item :relays, safe_join([fa_icon('exchange fw'), t('admin.relays.title')]), admin_relays_path, highlights_on: %r{/admin/relays}, if: -> { !limited_federation_mode? && current_user.can?(:manage_federation) }
    end

    n.item :sidekiq, safe_join([fa_icon('diamond fw'), 'Sidekiq']), sidekiq_path, link_html: { target: 'sidekiq' }, if: -> { current_user.can?(:view_devops) }
    n.item :pghero, safe_join([fa_icon('database fw'), 'PgHero']), pghero_path, link_html: { target: 'pghero' }, if: -> { current_user.can?(:view_devops) }
    n.item :logout, safe_join([fa_icon('sign-out fw'), t('auth.logout')]), destroy_user_session_path, link_html: { 'data-method' => 'delete' }
  end
end
