# frozen_string_literal: true

class Admin::DistributeTermsOfServiceNotificationWorker
  include Sidekiq::Worker

  def perform(terms_of_service_id)
    terms_of_service = TermsOfService.find(terms_of_service_id)

    terms_of_service.scope_for_notification.find_each do |user|
      UserMailer.terms_of_service_changed(user, terms_of_service).deliver_later!
    end
  rescue ActiveRecord::RecordNotFound
    true
  end
end
