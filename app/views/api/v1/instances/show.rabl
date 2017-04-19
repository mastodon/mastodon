object false

node(:uri)         { site_hostname }
node(:title)       { Setting.site_title }
node(:description) { Setting.site_description }
node(:extended_description) { Setting.site_extended_description }
node(:email)       { Setting.site_contact_email }
node(:contact_username)     { Setting.site_contact_username }
node(:contact_email)        { Setting.site_contact_email }
node(:open_registrations)   { Setting.open_registrations }
node(:user_count)           { @instance_presenter.user_count }
node(:status_count)         { @instance_presenter.status_count }
node(:domain_count)         { @instance_presenter.domain_count }