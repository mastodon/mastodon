# frozen_string_literal: true

Chewy.strategy(:mastodon) do
  sender = Account.find_by!(username: 'genya0407_dummy')
  Status.first.favourites.create!(account: sender, emoji: '😀')
  Status.second.favourites.create!(account: sender, emoji: 'https://storage.social.camph.net/drive/a2650c6f-2a08-412a-b4f1-97457608bea8.png')
end
