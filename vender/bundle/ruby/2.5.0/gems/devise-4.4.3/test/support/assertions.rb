# frozen_string_literal: true

require 'active_support/test_case'

class ActiveSupport::TestCase
  def assert_blank(assertion)
    assert assertion.blank?
  end

  def assert_present(assertion)
    assert assertion.present?
  end

  def assert_email_sent(address = nil, &block)
    assert_difference('ActionMailer::Base.deliveries.size', &block)
    if address.present?
      assert_equal address, ActionMailer::Base.deliveries.last['to'].to_s
    end
  end

  def assert_email_not_sent(&block)
    assert_no_difference('ActionMailer::Base.deliveries.size', &block)
  end

  def assert_raise_with_message(exception_klass, message, &block)
    exception = assert_raise exception_klass, &block
    assert_equal exception.message, message,
      "The expected message was #{message} but your exception throwed #{exception.message}"
  end
end
