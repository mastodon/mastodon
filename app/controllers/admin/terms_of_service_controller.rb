# frozen_string_literal: true

class Admin::TermsOfServiceController < Admin::BaseController
  def index
    authorize :terms_of_service, :index?
    @terms_of_service = TermsOfService.published.first
  end
end
