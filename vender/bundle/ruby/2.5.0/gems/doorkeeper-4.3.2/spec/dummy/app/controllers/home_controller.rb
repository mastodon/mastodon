class HomeController < ApplicationController
  def index
  end

  def sign_in
    session[:user_id] = if Rails.env.development?
                          User.first || User.create!(name: 'Joe', password: 'sekret')
                        else
                          User.first
                        end
    redirect_to '/'
  end

  def callback
    render plain: 'ok'
  end
end
