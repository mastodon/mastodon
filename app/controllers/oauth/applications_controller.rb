class Oauth::ApplicationsController < Doorkeeper::ApplicationsController
  before_action :authenticate_user!

  def index
    @applications = current_user.oauth_applications
  end

  def create
    @application = Doorkeeper::Application.new(application_params)
    @application.owner = current_user

    if @application.save
      redirect_to oauth_application_url(@application)
    else
      render :new
    end
  end
end
