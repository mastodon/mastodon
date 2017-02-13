# frozen_string_literal: true

class UnfavouriteService < BaseService
  def call(account, status)
    favourite = Favourite.find_by!(account: account, status: status)
    favourite.destroy!

    NotificationWorker.perform_async(build_xml(favourite), account.id, status.account_id) unless status.local?

    favourite
  end

  private

  def build_xml(favourite)
    Nokogiri::XML::Builder.new do |xml|
      entry(xml, true) do
        unique_id xml, Time.now.utc, favourite.id, 'Favourite'
        title xml, "#{favourite.account.acct} no longer favourites a status by #{favourite.status.account.acct}"

        author(xml) do
          include_author xml, favourite.account
        end

        object_type xml, :activity
        verb xml, :unfavorite
        in_reply_to xml, TagManager.instance.uri_for(favourite.status), TagManager.instance.url_for(favourite.status)

        target(xml) do
          include_target xml, favourite.status
        end
      end
    end.to_xml
  end
end
