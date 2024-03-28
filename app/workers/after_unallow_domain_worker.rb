# frozen_string_literal: true

class AfterUnallowDomainWorker < ApplicationWorker
  def perform(domain)
    AfterUnallowDomainService.new.call(domain)
  end
end
