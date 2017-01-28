# frozen_string_literal: true

SimpleNavigation::Configuration.run do |navigation|
  navigation.items do |primary|
    primary.item :web, safe_join([fa_icon('chevron-left fw'), t('settings.back')]), root_url

    primary.item :settings, safe_join([fa_icon('cog fw'), t('settings.settings')]), settings_profile_url do |settings|
      settings.item :profile, safe_join([fa_icon('user fw'), t('settings.edit_profile')]), settings_profile_url
      settings.item :preferences, safe_join([fa_icon('sliders fw'), t('settings.preferences')]), settings_preferences_url
      settings.item :password, safe_join([fa_icon('cog fw'), t('auth.change_password')]), edit_user_registration_url
      settings.item :two_factor_auth, safe_join([fa_icon('mobile fw'), t('settings.two_factor_auth')]), settings_two_factor_auth_url
      # settings.item :authorized_apps, safe_join([fa_icon('list fw'), 'Authorized Apps']), oauth_authorized_applications_url
    end

    primary.item :admin, safe_join([fa_icon('cogs fw'), 'Administration']), admin_accounts_url, if: proc { current_user.admin? } do |admin|
      admin.item :accounts, safe_join([fa_icon('users fw'), 'Accounts']), admin_accounts_url, highlights_on: %r{/admin/accounts}
      admin.item :pubsubhubbubs, safe_join([fa_icon('paper-plane-o fw'), 'PubSubHubbub']), admin_pubsubhubbub_index_url
      admin.item :domain_blocks, safe_join([fa_icon('lock fw'), 'Domain Blocks']), admin_domain_blocks_url
      admin.item :sidekiq, safe_join([fa_icon('diamond fw'), 'Sidekiq']), sidekiq_url
      admin.item :pghero, safe_join([fa_icon('database fw'), 'PgHero']), pghero_url
      admin.item :settings, safe_join([fa_icon('cogs fw'), 'Site Settings']), admin_settings_url
    end

    primary.item :logout, safe_join([fa_icon('sign-out fw'), t('auth.logout')]), destroy_user_session_url, link_html: { 'data-method' => 'delete' }
  end
end
