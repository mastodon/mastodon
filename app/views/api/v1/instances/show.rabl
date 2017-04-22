object false

node(:uri)         { site_hostname }
node(:title)       { Setting.site_title }
node(:description) { Setting.site_description }
node(:email)       { Setting.site_contact_email }
node(:version)     { Mastodon::VERSION }
