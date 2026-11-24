# frozen_string_literal: true

class Admin::ServerCheck::NoopRunner
  include Admin::ServerCheck::Runner

  def async?
    false
  end

  def authorized?(*)
    false
  end

  def run
    pending
  end
end
