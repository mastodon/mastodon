# frozen_string_literal: true

module Admin::ServerCheck::Runner
  extend ActiveSupport::Concern

  class_methods do
    def key
      name.demodulize.underscore.gsub(/_runner$/, '')
    end
  end

  def key
    self.class.key
  end

  # Whether or not this runner should run in the background
  def async?
    true
  end

  def sync?
    !async?
  end

  # Whether or not the given user can execute this runner
  def authorized?(_user)
    raise NotImplementedError, 'The runner class needs to implement the #authorized? method'
  end

  # @return Result
  def run
    raise NotImplementedError, 'The runner class needs to implement the #run method'
  end

  private

  def result(**)
    Admin::ServerCheck::Result.new(**)
  end

  def ok(**)
    result(status: :ok, **)
  end

  def pending(**)
    result(status: :pending, **)
  end

  def error(**)
    result(status: :error, **)
  end
end
