# frozen_string_literal: true
object @stream_entry

node(:type) { 'rich' }
node(:version) { '1.0' }
node(:title, &:title)
node(:author_name) { |entry| entry.account.display_name.blank? ? entry.account.username : entry.account.display_name }
node(:author_url) { |entry| account_url(entry.account) }
node(:provider_name) { Rails.configuration.x.local_domain }
node(:provider_url) { root_url }
node(:cache_age) { 86_400 }
node(:html, &:content)
node(:width) { @width }
node(:height) { @height }
