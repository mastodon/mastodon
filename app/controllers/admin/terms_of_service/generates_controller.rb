# frozen_string_literal: true

class Admin::TermsOfService::GeneratesController < Admin::BaseController
  before_action :set_instance_presenter

  def show
    authorize :terms_of_service, :create?

    @generator = TermsOfService::Generator.new(
      domain: @instance_presenter.domain,
      admin_email: @instance_presenter.contact.email
    )
  end

  def create
    authorize :terms_of_service, :create?

    @generator = TermsOfService::Generator.new(resource_params)

    if @generator.valid?
      TermsOfService.create!(text: @generator.render)
      redirect_to admin_terms_of_service_draft_path
    else
      render :show
    end
  end

  private

  def set_instance_presenter
    @instance_presenter = InstancePresenter.new
  end

  def resource_params
    params.require(:terms_of_service_generator).permit(*TermsOfService::Generator::VARIABLES)
  end
end
