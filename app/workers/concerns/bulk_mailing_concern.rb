# frozen_string_literal: true

module BulkMailingConcern
  def push_bulk_mailer(mailer_class, mailer_method, args_array)
    raise ArgumentError, "No method #{mailer_method} on class #{mailer_class.name}" unless mailer_class.respond_to?(mailer_method)

    job_class = ActionMailer::MailDeliveryJob

    Sidekiq::Client.push_bulk({
      'class' => Sidekiq::ActiveJob::Wrapper,
      'wrapped' => job_class,
      'queue' => mailer_class.deliver_later_queue_name,
      'args' => args_array.map do |args|
        [
          job_class.new(
            mailer_class.name,
            mailer_method.to_s,
            'deliver_now',
            args: args
          ).serialize,
        ]
      end,
    })
  end
end
