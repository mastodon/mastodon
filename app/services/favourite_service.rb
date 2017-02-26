# frozen_string_literal: true

class FavouriteService < BaseService
  # Favourite a status and notify remote user
  # @param [Account] account
  # @param [Status] status
  # @return [Favourite]
  def call(account, status)
    raise Mastodon::NotPermittedError unless status.permitted?(account)

    favourite = Favourite.create!(account: account, status: status)

    if status.local?
      NotifyService.new.call(favourite.status.account, favourite)
    else
      NotificationWorker.perform_async(build_xml(favourite), account.id, status.account_id)
    end

    favourite
  end

  private

  def build_xml(favourite)
    description = "#{favourite.account.acct} favourited a status by #{favourite.status.account.acct}"

    Nokogiri::XML::Builder.new do |xml|
      entry(xml, true) do
        unique_id xml, favourite.created_at, favourite.id, 'Favourite'
        title xml, description
        content xml, description

        author(xml) do
          include_author xml, favourite.account
        end

        object_type xml, :activity
        verb xml, :favorite
        in_reply_to xml, TagManager.instance.uri_for(favourite.status), TagManager.instance.url_for(favourite.status)

        target(xml) do
          include_target xml, favourite.status
        end
      end
    end.to_xml
  end
end
