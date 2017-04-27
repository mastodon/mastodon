# frozen_string_literal: true
object @stream_entry

node(:type) { 'rich' }
node(:version) { '1.0' }
node(:title, &:title)
node(:author_name) { |entry| entry.account.display_name.blank? ? entry.account.username : entry.account.display_name }
node(:author_url) { |entry| account_url(entry.account) }
node(:provider_name) { site_hostname }
node(:provider_url) { root_url }
node(:cache_age) { 86_400 }
node(:html) { |entry| "<iframe src=\"#{embed_account_stream_entry_url(entry.account, entry)}\" style=\"width: 100%; overflow: hidden\" frameborder=\"0\" width=\"#{@width}\" height=\"#{@height}\" scrolling=\"no\"></iframe>" }
node(:width) { @width }
node(:height) { @height }
