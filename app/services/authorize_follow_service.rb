# frozen_string_literal: true

class AuthorizeFollowService < BaseService
  def call(source_account, target_account)
    follow_request = FollowRequest.find_by!(account: source_account, target_account: target_account)
    follow_request.authorize!
    NotificationWorker.perform_async(build_xml(follow_request), target_account.id, source_account.id) unless source_account.local?
  end

  private

  def build_xml(follow_request)
    Nokogiri::XML::Builder.new do |xml|
      entry(xml, true) do
        author(xml) do
          include_author xml, follow_request.target_account
        end

        object_type xml, :activity
        verb xml, :authorize

        target(xml) do
          author(xml) do
            include_author xml, follow_request.account
          end

          object_type xml, :activity
          verb xml, :request_friend

          target(xml) do
            include_author xml, follow_request.target_account
          end
        end
      end
    end.to_xml
  end
end
