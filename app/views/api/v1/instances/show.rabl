object false

node(:uri)         { Rails.configuration.x.local_domain }
node(:title)       { Setting.site_title }
node(:description) { Setting.site_description }
node(:email)       { Setting.site_contact_email }
