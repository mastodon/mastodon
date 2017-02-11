# frozen_string_literal: true

class FavouriteService < BaseService
  # Favourite a status and notify remote user
  # @param [Account] account
  # @param [Status] status
  # @return [Favourite]
  def call(account, status)
    raise Mastodon::NotPermitted unless status.permitted?(account)

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
    Nokogiri::XML::Builder.new do |xml|
      entry(xml, true) do
        title xml, "#{favourite.account.acct} favourited a status by #{favourite.status.account.acct}"

        author(xml) do
          include_author xml, favourite.account
        end

        object_type xml, :activity
        verb xml, :favourite

        target(xml) do
          author(xml) do
            include_author xml, favourite.status.account
          end

          include_entry xml, favourite.status.stream_entry
        end
      end
    end.to_xml
  end
end
