# frozen_string_literal: true

class Admin::TermsOfService::HistoriesController < Admin::BaseController
  def show
    authorize :terms_of_service, :index?
    @terms_of_service = TermsOfService.published.all
  end
end
