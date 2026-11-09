# frozen_string_literal: true

class Admin::ServerCheck::Result
  attr_reader :status, :data, :severity

  def initialize(status:, data: {}, severity: :critical)
    @status = status
    @data = data
    @severity = severity
  end

  def ok?
    status == :ok
  end

  def pending?
    status == :pending
  end

  def error?
    status == :error
  end
end
