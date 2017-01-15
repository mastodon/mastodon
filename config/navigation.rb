# frozen_string_literal: true

SimpleNavigation::Configuration.run do |navigation|
  navigation.items do |primary|
    primary.item :accounts, safe_join([fa_icon('users fw'), 'Accounts']), admin_accounts_url
    primary.item :pubsubhubbubs, safe_join([fa_icon('paper-plane-o fw'), 'PubSubHubbub']), admin_pubsubhubbub_index_url
    primary.item :domain_blocks, safe_join([fa_icon('lock fw'), 'Domain Blocks']), admin_domain_blocks_url
    primary.item :sidekiq, safe_join([fa_icon('diamond fw'), 'Sidekiq']), sidekiq_url
    primary.item :pghero, safe_join([fa_icon('database fw'), 'PgHero']), pghero_url
    primary.item :settings, safe_join([fa_icon('cogs fw'), 'Site Settings']), admin_settings_url
  end
end
