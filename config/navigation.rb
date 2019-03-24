# frozen_string_literal: true

SimpleNavigation::Configuration.run do |navigation|
  navigation.items do |primary|
    primary.item :web, safe_join([fa_icon('chevron-left fw'), t('settings.back')]), root_url

    primary.item :settings, safe_join([fa_icon('cog fw'), t('settings.settings')]), settings_profile_url do |settings|
      settings.item :profile, safe_join([fa_icon('user fw'), t('settings.edit_profile')]), settings_profile_url, highlights_on: %r{/settings/profile|/settings/migration}
      settings.item :featured_tags, safe_join([fa_icon('hashtag fw'), t('settings.featured_tags')]), settings_featured_tags_url
      settings.item :preferences, safe_join([fa_icon('sliders fw'), t('settings.preferences')]), settings_preferences_url
      settings.item :notifications, safe_join([fa_icon('bell fw'), t('settings.notifications')]), settings_notifications_url
      settings.item :password, safe_join([fa_icon('lock fw'), t('auth.security')]), edit_user_registration_url, highlights_on: %r{/auth/edit|/settings/delete}
      settings.item :two_factor_authentication, safe_join([fa_icon('mobile fw'), t('settings.two_factor_authentication')]), settings_two_factor_authentication_url, highlights_on: %r{/settings/two_factor_authentication}
      settings.item :import, safe_join([fa_icon('cloud-upload fw'), t('settings.import')]), settings_import_url
      settings.item :export, safe_join([fa_icon('cloud-download fw'), t('settings.export')]), settings_export_url
      settings.item :authorized_apps, safe_join([fa_icon('list fw'), t('settings.authorized_apps')]), oauth_authorized_applications_url
      settings.item :identity_proofs, safe_join([fa_icon('key fw'), t('settings.identity_proofs')]), settings_identity_proofs_path, highlights_on: %r{/settings/identity_proofs*}
    end

    primary.item :relationships, safe_join([fa_icon('users fw'), t('settings.relationships')]), relationships_url
    primary.item :filters, safe_join([fa_icon('filter fw'), t('filters.index.title')]), filters_path, highlights_on: %r{/filters}
    primary.item :invites, safe_join([fa_icon('user-plus fw'), t('invites.title')]), invites_path, if: proc { Setting.min_invite_role == 'user' }

    primary.item :development, safe_join([fa_icon('code fw'), t('settings.development')]), settings_applications_url do |development|
      development.item :your_apps, safe_join([fa_icon('list fw'), t('settings.your_apps')]), settings_applications_url, highlights_on: %r{/settings/applications}
    end

    primary.item :moderation, safe_join([fa_icon('gavel fw'), t('moderation.title')]), admin_reports_url, if: proc { current_user.staff? } do |admin|
      admin.item :action_logs, safe_join([fa_icon('bars fw'), t('admin.action_logs.title')]), admin_action_logs_url
      admin.item :reports, safe_join([fa_icon('flag fw'), t('admin.reports.title')]), admin_reports_url, highlights_on: %r{/admin/reports}
      admin.item :accounts, safe_join([fa_icon('users fw'), t('admin.accounts.title')]), admin_accounts_url, highlights_on: %r{/admin/accounts}
      admin.item :invites, safe_join([fa_icon('user-plus fw'), t('admin.invites.title')]), admin_invites_path
      admin.item :tags, safe_join([fa_icon('tag fw'), t('admin.tags.title')]), admin_tags_path
      admin.item :instances, safe_join([fa_icon('cloud fw'), t('admin.instances.title')]), admin_instances_url(limited: '1'), highlights_on: %r{/admin/instances|/admin/domain_blocks}, if: -> { current_user.admin? }
      admin.item :email_domain_blocks, safe_join([fa_icon('envelope fw'), t('admin.email_domain_blocks.title')]), admin_email_domain_blocks_url, highlights_on: %r{/admin/email_domain_blocks}, if: -> { current_user.admin? }
    end

    primary.item :admin, safe_join([fa_icon('cogs fw'), t('admin.title')]), admin_dashboard_url, if: proc { current_user.staff? } do |admin|
      admin.item :dashboard, safe_join([fa_icon('tachometer fw'), t('admin.dashboard.title')]), admin_dashboard_url
      admin.item :settings, safe_join([fa_icon('cogs fw'), t('admin.settings.title')]), edit_admin_settings_url, if: -> { current_user.admin? }
      admin.item :custom_emojis, safe_join([fa_icon('smile-o fw'), t('admin.custom_emojis.title')]), admin_custom_emojis_url, highlights_on: %r{/admin/custom_emojis}
      admin.item :relays, safe_join([fa_icon('exchange fw'), t('admin.relays.title')]), admin_relays_url, if: -> { current_user.admin? }, highlights_on: %r{/admin/relays}
      admin.item :subscriptions, safe_join([fa_icon('paper-plane-o fw'), t('admin.subscriptions.title')]), admin_subscriptions_url, if: -> { current_user.admin? }
      admin.item :sidekiq, safe_join([fa_icon('diamond fw'), 'Sidekiq']), sidekiq_url, link_html: { target: 'sidekiq' }, if: -> { current_user.admin? }
      admin.item :pghero, safe_join([fa_icon('database fw'), 'PgHero']), pghero_url, link_html: { target: 'pghero' }, if: -> { current_user.admin? }
    end

    primary.item :logout, safe_join([fa_icon('sign-out fw'), t('auth.logout')]), destroy_user_session_url, link_html: { 'data-method' => 'delete' }
  end
end
