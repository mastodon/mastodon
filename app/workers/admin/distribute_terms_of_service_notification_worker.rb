# frozen_string_literal: true

class Admin::DistributeTermsOfServiceNotificationWorker
  include Sidekiq::IterableJob
  include BulkMailingConcern

  def build_enumerator(terms_of_service_id, cursor:)
    @terms_of_service = TermsOfService.find(terms_of_service_id)

    active_record_batches_enumerator(@terms_of_service.scope_for_notification, cursor:)
  rescue ActiveRecord::RecordNotFound
    nil
  end

  def each_iteration(batch_of_users, _terms_of_service_id)
    push_bulk_mailer(UserMailer, :terms_of_service_changed, batch_of_users.map { |user| [user, @terms_of_service] })
  end

  def on_start
    @terms_of_service.scope_for_interstitial.in_batches.update_all(require_tos_interstitial: true)
  end
end
