# frozen_string_literal: true

%w(
  abuse
  account
  accounts
  admin
  administration
  administrator
  admins
  help
  helpdesk
  instance
  mod
  moderator
  moderators
  mods
  owner
  root
  security
  server
  staff
  support
  webmaster
).each do |str|
  UsernameBlock.create_with(username: str, exact: true).find_or_create_by(username: str)
end

%w(
  mastodon
  mastadon
).each do |str|
  UsernameBlock.create_with(username: str, exact: false).find_or_create_by(username: str)
end
