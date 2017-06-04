object false

node(:uri)                    { site_hostname }
node(:title)                  { Setting.site_title }
node(:description)            { Setting.site_description }
node(:email)                  { Setting.site_contact_email }
node(:version)                { Mastodon::Version.to_s }
node(:streaming_api_base_url) { Rails.configuration.x.streaming_api_base_url }
