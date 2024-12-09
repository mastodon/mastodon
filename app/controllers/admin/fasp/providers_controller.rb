# frozen_string_literal: true

class Admin::Fasp::ProvidersController < Admin::BaseController
  before_action :set_provider, only: [:show, :edit, :update, :destroy]

  def index
    authorize [:admin, :fasp, :provider], :index?

    @providers = Fasp::Provider.order(confirmed: :asc, created_at: :desc)
  end

  def show
    authorize [:admin, @provider], :show?
  end

  def edit
    authorize [:admin, @provider], :update?
  end

  def update
    authorize [:admin, @provider], :update?

    if @provider.update(provider_params)
      redirect_to admin_fasp_providers_path
    else
      render :edit
    end
  end

  def destroy
    authorize [:admin, @provider], :destroy?

    @provider.destroy

    redirect_to admin_fasp_providers_path
  end

  private

  def provider_params
    params.require(:provider).permit(enabled_capabilities: {})
  end

  def set_provider
    @provider = Fasp::Provider.find(params[:id])
  end
end
