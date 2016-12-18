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
node(:html) { |entry| "<div style=\"position: relative; height: 0; overflow: hidden; padding-top: 30px; padding-bottom: 56.25%\"><iframe src=\"#{embed_account_stream_entry_url(entry.account, entry)}\" style=\"position: absolute; top: 0; left: 0; width: 100%; height: 100%; overflow: hidden\" frameborder=\"0\" width=\"#{@width}\" scrolling=\"no\"></iframe></div>" }
node(:width) { @width }
node(:height) { nil }
