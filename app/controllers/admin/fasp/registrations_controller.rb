# frozen_string_literal: true

class Admin::Fasp::RegistrationsController < Admin::BaseController
  before_action :set_provider

  def new
    authorize [:admin, @provider], :create?
  end

  def create
    authorize [:admin, @provider], :create?

    @provider.update_info!(confirm: true)

    redirect_to edit_admin_fasp_provider_path(@provider)
  end

  private

  def set_provider
    @provider = Fasp::Provider.find(params[:provider_id])
  end
end
